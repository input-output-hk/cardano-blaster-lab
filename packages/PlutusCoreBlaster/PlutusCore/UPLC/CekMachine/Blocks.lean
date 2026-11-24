import PlutusCore.UPLC.CekMachine.IndexedCode
import PlutusCore.UPLC.CekMachine.StepRules

namespace PlutusCore.UPLC.CekMachine.Blocks

open Lean Elab Command Blaster Blaster.Optimize

private def isPending (state : Expr) : Bool :=
  state.isAppOfArity ``State.Eval 3 || state.isAppOfArity ``State.Return 2

private def stateRefl (state : Expr) : Expr :=
  mkApp2 (mkConst ``Eq.refl [levelOne]) (mkConst ``State) state

/-- Return the next expression and an equality with the original `step`. -/
private def fallbackStep (sv state : Expr) : Expr × Expr :=
  match state with
  | .app (.app (.app (.const ``State.Eval _) stack) env) term =>
    (mkApp3 (mkConst ``evalTerm) stack env term,
     mkApp4 (mkConst ``step_evalTerm) sv stack env term)
  | .app (.app (.const ``State.Return _)
      (.app (.app (.app (.const ``List.cons _) _) (.const ``Frame.ForceFrame _)) stack)) value =>
    (mkApp3 (mkConst ``forceValue) sv stack value,
     mkApp3 (mkConst ``step_forceValue) sv stack value)
  | _ =>
    let next := mkApp2 (mkConst ``step) sv state
    (next, stateRefl next)

private def terminalProof? (sv state fuel : Expr) : Option Expr :=
  match state with
  | .app (.const ``State.Halt _) value => some (mkApp3 (mkConst ``runSteps_halt) sv value fuel)
  | .const ``State.Error _ => some (mkApp2 (mkConst ``runSteps_error) sv fuel)
  | .const ``State.BudgetExhausted _ => some (mkApp2 (mkConst ``runSteps_budgetExhausted) sv fuel)
  | _ => none

initialize registerTraceClass `UPLC.CekBlocks.certificate

/-- The native matchers propose rewrites. Check a proof of the equality of
the actual input and returned expression in Blaster's current local context.
An unresolved metavariable or a rejected equality leaves the rewrite unused. -/
def checkRewrite (before after proof : Expr) : TranslateEnvT (Option Expr) := do
  let after ← hashcons after
  let goal := mkApp3 (mkConst ``Eq [levelOne]) (mkConst ``State) before after
  let some (goal, proof) ← (try
      pure (some (← instantiateSharedMVars goal, ← instantiateSharedMVars proof))
    catch _ => pure none) | return none
  if goal.hasMVar || proof.hasMVar || goal.hasLooseBVars || proof.hasLooseBVars then return none
  let env ← getEnv
  let lctx := (← get).optEnv.ctx.ctx
  -- Applying the identity at the exact equality checks both the equality
  -- type and the certificate against that type in a single kernel call.
  let checked := mkApp (.lam `h goal (.bvar 0) .default) proof
  let .ok _ := Kernel.check env lctx checked
    | trace[UPLC.CekBlocks.certificate] "CEK certificate rejected by the kernel"
      return none
  setRestart
  return some after

private def finish (indexed : Option IndexedProgram) (state : Expr) : TranslateEnvT Expr := do
  let some program := indexed | return state
  let state ← try instantiateSharedMVars state catch _ => pure state
  return program.finish state

/-- Compose the certificates of the chosen steps and check the resulting
equality once before handing a new expression to Blaster. -/
private def rewriteRunSteps (indexed : Option IndexedProgram) (base : Expr → Expr → Option Expr) :
    OptFn :=
  let advance := indexed.map (·.advance base) |>.getD base
  fun f args => do
    let #[sv, initial, budgetExpr] := args | return none
    if initial.hasLooseBVars || sv.hasLooseBVars then return none
    let original := mkApp3 f sv initial budgetExpr
    if let some proof := terminalProof? sv initial budgetExpr then
      return ← checkRewrite original (← finish indexed initial) proof
    let .lit (.natVal budget) := budgetExpr | return none
    unless isPending initial do return none
    let run := fun state fuel => mkApp3 f sv state (mkNatLit fuel)
    let extend := fun (prev : Option Expr) current next proof =>
      match prev with
      | none => proof
      | some h => mkApp6 (mkConst ``Eq.trans [levelOne]) (mkConst ``State) original current next h proof
    let nextStep := fun state next fuel h =>
      mkApp5 (mkConst ``runSteps_after_step) sv state next (mkNatLit fuel) h
    let mut state := initial
    let mut fuel := budget
    let mut proof : Option Expr := none
    while fuel > 0 && isPending state do
      let current := run state fuel
      if let some program := indexed then
        if let some (next, remaining, h) := program.advancePrefix sv state fuel then
          proof := some (extend proof current (run next remaining) h)
          state := next
          fuel := remaining
          continue
      let some next := advance sv state | break
      let remaining := fuel - 1
      proof := some (extend proof current (run next remaining) (nextStep state next remaining (stateRefl next)))
      state := next
      fuel := remaining
    let current := run state fuel
    if let some h := terminalProof? sv state (mkNatLit fuel) then
      let result ← finish indexed state
      return ← checkRewrite original result (extend proof current result h)
    -- At zero fuel an opaque builtin result can still be a true Error.
    if isPending state then
      if fuel == 0 then
        let result := mkConst ``State.BudgetExhausted
        return ← checkRewrite original result (extend proof current result (stateRefl result))
      let (next, h) := fallbackStep sv state
      let result := run next (fuel - 1)
      return ← checkRewrite original result (extend proof current result (nextStep state next (fuel - 1) h))
    let some h := proof | return none
    checkRewrite original current h

private def rewriteStep (base : Expr → Expr → Option Expr) : OptFn := fun f args => do
  let #[sv, state] := args | return none
  let some next := base sv state | return none
  checkRewrite (mkApp2 f sv state) next (stateRefl next)

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
