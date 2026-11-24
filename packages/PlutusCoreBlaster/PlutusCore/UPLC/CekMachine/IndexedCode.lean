import Blaster.Optimize.Env.Extension
import PlutusCore.UPLC.CekMachine

namespace PlutusCore.UPLC.CekMachine.Blocks

open Lean Elab Command Blaster Blaster.Optimize
open PlutusCore.UPLC.CekMachine
open PlutusCore.UPLC.Term (Program Term)

/-- The code to enter after pushing a static application or force prefix.
Application frames capture the environment supplied at runtime. -/
private structure EvalPrefix where
  frames : List (Option Expr) := []
  steps : Nat := 0
  target : Nat
  deriving Inhabited

private structure Instruction where
  original : Expr
  layer : Expr
  addr : Expr
  spine : EvalPrefix
  deriving Inhabited

structure IndexedProgram where
  private mk ::
  private label : Name
  private code : Array Instruction
  private entry : Nat

private structure Compiler where
  code : Array Instruction := #[]
  seen : Std.HashMap Expr Nat := {}

private abbrev CompileM := StateT Compiler CoreM

private def pushPrefix (arg : Option Expr) (next : EvalPrefix) : EvalPrefix :=
  { next with frames := arg :: next.frames, steps := next.steps + 1 }

mutual
  private partial def compileTerm (label : Name) (term : Expr) : CompileM Nat := do
    if let some pc := (← get).seen[term]? then return pc
    let (layer, spine) ←
      match term with
      | .app (.app (.const ``PlutusCore.UPLC.Term.Term.Apply _) fn) arg => do
        let fn ← compileTerm label fn
        let arg ← compileTerm label arg
        let code := (← get).code
        let arg := code[arg]!.addr
        pure (mkApp2 (mkConst ``PlutusCore.UPLC.Term.Term.Apply) code[fn]!.addr arg,
          some (pushPrefix (some arg) code[fn]!.spine))
      | .app (.const ctor []) body =>
        if ctor == ``PlutusCore.UPLC.Term.Term.Lam || ctor == ``PlutusCore.UPLC.Term.Term.Delay || ctor == ``PlutusCore.UPLC.Term.Term.Force then do
          let child ← compileTerm label body
          let child := (← get).code[child]!
          let spine := if ctor == ``PlutusCore.UPLC.Term.Term.Force then some (pushPrefix none child.spine) else none
          pure (mkApp (mkConst ctor) child.addr, spine)
        else if ctor == ``PlutusCore.UPLC.Term.Term.Var || ctor == ``PlutusCore.UPLC.Term.Term.Const || ctor == ``PlutusCore.UPLC.Term.Term.Builtin then
          pure (term, none)
        else throwError "unsupported closed UPLC term {term}"
      | .app (.app (.const ``PlutusCore.UPLC.Term.Term.Constr _) tag) fields =>
        pure (mkApp2 (mkConst ``PlutusCore.UPLC.Term.Term.Constr) tag (← compileTerms label fields), none)
      | .app (.app (.const ``PlutusCore.UPLC.Term.Term.Case _) scrutinee) arms => do
        let pc ← compileTerm label scrutinee
        let addr := (← get).code[pc]!.addr
        pure (mkApp2 (mkConst ``PlutusCore.UPLC.Term.Term.Case) addr (← compileTerms label arms), none)
      | .const ``PlutusCore.UPLC.Term.Term.Error _ => pure (term, none)
      | _ => throwError "expected a closed UPLC constructor, got {term}"
    let pc := (← get).code.size
    let name := Name.num label pc
    -- Each address is definitionally equal to its source subterm. Only the
    -- one-layer instruction is stored in the declaration; its children use
    -- addresses already emitted by the compiler.
    addDecl (.defnDecl {
      name, levelParams := [], type := mkConst ``PlutusCore.UPLC.Term.Term, value := layer
      hints := .regular (pc + 1).toUInt32, safety := .safe })
    let entry : Instruction := {
      original := term
      layer
      addr := mkConst name
      spine := spine.getD { target := pc } }
    modify fun s => { code := s.code.push entry, seen := s.seen.insert term pc }
    return pc

  private partial def compileTerms (label : Name) (terms : Expr) : CompileM Expr := do
    match terms with
    | .app (.const ``List.nil _) _ => return terms
    | .app (.app (.app cons@(.const ``List.cons _) ty) term) rest =>
      let pc ← compileTerm label term
      let addr := (← get).code[pc]!.addr
      return mkApp3 cons ty addr (← compileTerms label rest)
    | _ => throwError "expected a closed list of UPLC terms, got {terms}"
end

/-- Compile a closed program once. Blaster keeps references as leaves and the
CEK callbacks enter them when control reaches the corresponding instruction. -/
def compileIndexedProgram (stx : Lean.Syntax) : CommandElabM IndexedProgram := do
  let program ← liftTermElabM do
    let expr ← Elab.Term.elabTermEnsuringType stx (mkConst ``Program)
    Elab.Term.synthesizeSyntheticMVarsNoPostponing
    let expr ← instantiateMVars expr
    if expr.hasFVar || expr.hasMVar then throwErrorAt stx "expected a closed UPLC program"
    Meta.reduce expr
  let .app (.app (.const ``Program.Program _) _) root := program
    | throwErrorAt stx "expected a closed UPLC program"
  let label ← liftCoreM <| mkFreshUserName `_cek_block
  let (entry, state) ← liftCoreM ((compileTerm label root).run {})
  for instruction in state.code do
    -- A registered head lets a zero-argument definition survive normConst.
    -- The ordinary optimizer can continue simplifying symbolic fields of
    -- the enclosing CEK state without expanding the static source tree.
    let name := instruction.addr.constName!
    blasterExt.add { head := name, declName := name, fn := default } .local
  return { label, code := state.code, entry }

private def IndexedProgram.address? (program : IndexedProgram) (e : Expr) : Option Nat := do
  let .const (.num label pc) [] := e | none
  guard (label == program.label && pc < program.code.size)
  return pc

private def IndexedProgram.locate? (program : IndexedProgram) (e : Expr) : Option Nat :=
  program.address? e <|>
    if e.hash == program.code[program.entry]!.original.hash &&
      e == program.code[program.entry]!.original then some program.entry else none

private def IndexedProgram.expand (program : IndexedProgram) (e : Expr) : Expr :=
  e.replace fun sub => (program.address? sub).map fun pc => program.code[pc]!.original

/-- Only the current instruction is decoded for the generated CEK equation.
Child code addresses are retained in values and pending frames. -/
def IndexedProgram.advance (program : IndexedProgram) (base : Expr → Expr → Option Expr)
    (sv state : Expr) : Option Expr :=
  match state with
  | .app (.app (.app ctor@(.const ``State.Eval _) stack) env) term =>
    match program.locate? term with
    | some pc => base sv (mkApp3 ctor stack env program.code[pc]!.layer)
    | none => base sv state
  | _ => base sv state

/-- Enter a compiled prefix with one index lookup. If the fuel runs out inside
the prefix, CEK is still evaluating and returns `BudgetExhausted`. -/
def IndexedProgram.advancePrefix (program : IndexedProgram) (state : Expr)
    (fuel : Nat) : Option (Expr × Nat) := do
  let .app (.app (.app ctor@(.const ``State.Eval _) stack) env) term := state | none
  let pc ← program.locate? term
  let spine := program.code[pc]!.spine
  guard (spine.steps > 0)
  if fuel ≤ spine.steps then return (mkConst ``State.BudgetExhausted, 0)
  let stack := spine.frames.foldl (init := stack) fun stack frame =>
    let frame := match frame with
      | some arg => mkApp2 (mkConst ``Frame.LeftApplicationToTerm) arg env
      | none => mkConst ``Frame.ForceFrame
    mkApp3 (mkConst ``List.cons [levelZero]) (mkConst ``Frame) frame stack
  return (mkApp3 ctor stack env program.code[spine.target]!.addr, fuel - spine.steps)

/-- Expand code references before a final value can be observed by the spec. -/
def IndexedProgram.finish (program : IndexedProgram) (state : Expr) : Expr :=
  if state.isAppOfArity ``State.Halt 1 then program.expand state else state

end PlutusCore.UPLC.CekMachine.Blocks
