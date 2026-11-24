import PlutusCore.UPLC.CekMachine.BlockLemmas
import PlutusCore.UPLC.CekMachine.IndexedCode
import PlutusCore.UPLC.CekMachine.StepRules

namespace PlutusCore.UPLC.CekMachine.Blocks

open Lean Elab Command Blaster Blaster.Optimize

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
  while fuel > 0 && isPending state do
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
