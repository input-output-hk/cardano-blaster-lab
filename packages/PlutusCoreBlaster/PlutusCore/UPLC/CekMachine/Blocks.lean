import PlutusCore.UPLC.CekMachine.BlockLemmas
import PlutusCore.UPLC.CekMachine.IndexedCode
import PlutusCore.UPLC.CekMachine.StepRules

namespace PlutusCore.UPLC.CekMachine.Blocks

open Lean Elab Command Blaster Blaster.Optimize
open PlutusCore.UPLC.CekValue (CekValue)
open PlutusCore.UPLC.Term (BuiltinFun Const)

private def isPending (state : Expr) : Bool :=
  state.isAppOfArity ``State.Eval 3 || state.isAppOfArity ``State.Return 2

private def fallbackStep (sv state : Expr) : Expr :=
  match state with
  | .app (.app (.app (.const ``State.Eval _) stack) env) term =>
    mkApp3 (mkConst ``evalTerm) stack env term
  | .app (.app (.const ``State.Return _)
      (.app (.app (.app (.const ``List.cons _) _) (.const ``Frame.ForceFrame _)) stack)) value =>
    mkApp3 (mkConst ``forceValue) sv stack value
  | _ => mkApp2 (mkConst ``step) sv state

private def finish (indexed : Option IndexedProgram) (state : Expr) : TranslateEnvT Expr := do
  let some program := indexed | return state
  let state ← try instantiateSharedMVars state catch _ => pure state
  return program.finish state

/-- Recognize the argument shape of the two strict choice builtins. The
condition is boolean; `ChooseList` selects its first branch for an empty list. -/
private def builtinChoice? (state : Expr) : Option (Expr × Expr × Expr × Expr) := do
  let .app (.app (.app (.app (.const ``evalBuiltin []) _) stack) (.const builtin [])) args := state
    | none
  guard (builtin == ``BuiltinFun.IfThenElse || builtin == ``BuiltinFun.ChooseList)
  let .app (.app (.app (.const ``List.cons [.zero]) _) no) args := args | none
  let .app (.app (.app (.const ``List.cons [.zero]) _) yes) args := args | none
  let .app (.app (.app (.const ``List.cons [.zero]) _) value) tail := args | none
  guard (tail.isAppOfArity ``List.nil 1)
  let .app (.const ``CekValue.VCon []) (.app (.const ctor []) value) := value | none
  if builtin == ``BuiltinFun.IfThenElse then
    guard (ctor == ``Const.Bool)
    return (stack, value, yes, no)
  let dataType := mkConst ``PlutusCore.Data.Data
  let elementType ← match ctor with
    | ``Const.ConstList => some (mkConst ``Const)
    | ``Const.ConstDataList => some dataType
    | ``Const.ConstPairDataList => some (mkApp2 (mkConst ``Prod [levelZero, levelZero]) dataType dataType)
    | _ => none
  let empty :=
    if value.isAppOfArity ``List.nil 1 then mkConst ``Bool.true
    else if value.isAppOfArity ``List.cons 3 then mkConst ``Bool.false
    else mkApp2 (mkConst ``List.isEmpty [levelZero]) elementType value
  return (stack, empty, yes, no)

/-- Expose a choice directly, fusing a following force when both branch values
are delays. The transition entering `evalBuiltin` has already spent its fuel. -/
private def rewriteBuiltinChoice (f sv state : Expr) (fuel : Nat) : TranslateEnvT (Option Expr) := do
  let some (stack, cond, yes, no) := builtinChoice? state | return none
  if fuel == 0 then return some (← mkExpr (mkConst ``State.BudgetExhausted))
  let (yesState, noState, remaining) :=
    match stack, yes, no with
    | .app (.app (.app (.const ``List.cons [.zero]) _) (.const ``Frame.ForceFrame [])) stack,
      .app (.app (.const ``CekValue.VDelay []) yesTerm) yesEnv,
      .app (.app (.const ``CekValue.VDelay []) noTerm) noEnv =>
      (mkApp3 (mkConst ``State.Eval) stack yesEnv yesTerm,
        mkApp3 (mkConst ``State.Eval) stack noEnv noTerm, fuel - 1)
    | _, _, _ => (mkApp2 (mkConst ``State.Return) stack yes,
        mkApp2 (mkConst ``State.Return) stack no, fuel)
  setRestart
  let fuel := mkNatLit remaining
  if cond.isConstOf ``Bool.true then return some (← hashcons (mkApp3 f sv yesState fuel))
  if cond.isConstOf ``Bool.false then return some (← hashcons (mkApp3 f sv noState fuel))
  let onTrue := mkApp3 f sv yesState fuel
  let onFalse := mkApp3 f sv noState fuel
  let predicate ← mkApp3Expr (← mkEqOp) (← mkBoolType) (← hashcons cond) (← mkBoolTrue)
  let yes ← mkLambdaExpr `h .default predicate (← hashcons (onTrue.liftLooseBVars 0 1))
  let no ← mkLambdaExpr `h .default (← mkAppExpr (← mkPropNotOp) predicate)
    (← hashcons (onFalse.liftLooseBVars 0 1))
  return some (← mkApp4Expr (← mkBlasterDIteOp) (← mkExpr (mkConst ``State)) predicate yes no)

/-- Reduce saturated builtins whose arguments expose the necessary constructors.
The CEK transition that produced `evalBuiltin` has already spent its fuel. -/
private def reduceConstructorBuiltin? (state : Expr) : Option Expr := do
  let .app (.app (.app (.app (.const ``evalBuiltin []) _) stack) (.const builtin [])) args := state
    | none
  guard (builtin == ``BuiltinFun.UnConstrData || builtin == ``BuiltinFun.HeadList)
  let .app (.app (.app (.const ``List.cons [.zero]) _) arg) tail := args | none
  guard (tail.isAppOfArity ``List.nil 1)
  let .app (.const ``CekValue.VCon []) (.app (.const ctor []) value) := arg | none
  let result (c : Expr) := mkApp2 (mkConst ``State.Return) stack (mkApp (mkConst ``CekValue.VCon) c)
  if builtin == ``BuiltinFun.UnConstrData then
    guard (ctor == ``Const.Data)
    match value with
    | .app (.app (.const ``PlutusCore.Data.Data.Constr []) tag) fields =>
        let constType := mkConst ``Const
        let pair := mkApp4 (mkConst ``Prod.mk [levelZero, levelZero]) constType constType
          (mkApp (mkConst ``Const.Integer) tag) (mkApp (mkConst ``Const.ConstDataList) fields)
        return result (mkApp (mkConst ``Const.Pair) pair)
    | .app (.const ``PlutusCore.Data.Data.Map []) _ | .app (.const ``PlutusCore.Data.Data.List []) _
    | .app (.const ``PlutusCore.Data.Data.I []) _ | .app (.const ``PlutusCore.Data.Data.B []) _ =>
        return mkConst ``State.Error
    | _ => none
  else
    guard (ctor == ``Const.ConstList || ctor == ``Const.ConstDataList || ctor == ``Const.ConstPairDataList)
    match value with
    | .app (.const ``List.nil [.zero]) _ => return mkConst ``State.Error
    | .app (.app (.app (.const ``List.cons [.zero]) _) head) _ =>
      let value :=
        if ctor == ``Const.ConstDataList then mkApp (mkConst ``Const.Data) head
        else if ctor == ``Const.ConstPairDataList then mkApp (mkConst ``Const.PairData) head
        else head
      return result value
    | _ => none

/-- Advance deterministic transitions in one call to the optimizer extension.
A symbolic builtin result goes back through the same `runSteps` continuation. -/
private def rewriteRunSteps (indexed : Option IndexedProgram) (base : Expr → Expr → Option Expr) :
    OptFn := fun f args => do
  let #[sv, initial, fuel] := args | return none
  if initial.hasLooseBVars || sv.hasLooseBVars then return none
  if initial.isAppOfArity ``State.Halt 1 then
    setRestart
    return some (← hashcons (← finish indexed initial))
  if initial.isConstOf ``State.Error || initial.isConstOf ``State.BudgetExhausted then
    return some initial
  let .lit (.natVal budget) := fuel | return none
  unless isPending initial do return none
  let advance := indexed.map (·.advance base) |>.getD base
  let mut state := initial
  let mut fuel := budget
  while true do
    unless isPending state do
      if let some next := reduceConstructorBuiltin? state then
        state := next
        continue
      break
    if fuel == 0 then break
    if let some program := indexed then
      if let some (next, remaining) := program.advancePrefix state fuel then
        state := next
        fuel := remaining
        continue
    let some next := advance sv state | break
    state := next
    fuel := fuel - 1
  if state.isAppOfArity ``State.Halt 1 then
    setRestart
    return some (← hashcons (← finish indexed state))
  if state.isConstOf ``State.Error || state.isConstOf ``State.BudgetExhausted then
    return some (← hashcons state)
  -- A builtin completed on the last step can still return Error. Only an
  -- evaluation or return state is known to produce BudgetExhausted at zero.
  if fuel == 0 && isPending state then
    return some (← mkExpr (mkConst ``State.BudgetExhausted))
  if let some choice ← rewriteBuiltinChoice f sv state fuel then return some choice
  if isPending state then
    state := fallbackStep sv state
    fuel := fuel - 1
  setRestart
  return some (← hashcons (mkApp3 f sv state (mkNatLit fuel)))

private def rewriteStep (base : Expr → Expr → Option Expr) : OptFn := fun _ args => do
  let #[sv, state] := args | return none
  let some next := base sv state | return none
  setRestart
  return some (← hashcons next)

private def registerBlocks (indexed : Option IndexedProgram) : CommandElabM Unit := do
  let base := generatedCEKStep cekArityIndex
  blasterExt.add {
    head := ``runSteps
    declName := ``rewriteRunSteps
    fn := rewriteRunSteps indexed base
  } .local
  blasterExt.add { head := ``step, declName := ``rewriteStep, fn := rewriteStep base } .local

/-- Enable the generated CEK block runner in the current Lean section. -/
elab "#cek_blocks" : command => registerBlocks none

/-- Compile the supplied closed UPLC program and enable the indexed CEK block
runner in the current Lean section. Other inputs use the generated CEK rules. -/
elab "#index_uplc " program:term : command => do
  registerBlocks (some (← compileIndexedProgram program))

end PlutusCore.UPLC.CekMachine.Blocks
