import PlutusCore.UPLC.CekMachine

namespace PlutusCore.UPLC.CekMachine.Blocks

open PlutusCore.Default
open PlutusCore.UPLC.Builtins (expectedArgs)
open PlutusCore.UPLC.CekValue (CekValue Environment)
open PlutusCore.UPLC.Term (Term)

/-- Expose just the term constructor when optimizing a symbolic evaluation. -/
def evalTerm (stack : Stack) (env : Environment) : Term → State
  | .Var index =>
    match List.get?Internal env index with
    | some value => .Return stack value
    | none => .Error
  | .Const c => .Return stack (.VCon c)
  | .Lam body => .Return stack (.VLam body env)
  | .Delay body => .Return stack (.VDelay body env)
  | .Force body => .Eval (.ForceFrame :: stack) env body
  | .Apply fn arg => .Eval (.LeftApplicationToTerm arg env :: stack) env fn
  | .Constr index terms =>
    match terms with
    | term :: rest => .Eval (.ConstructorArgument index [] rest env :: stack) env term
    | [] => .Return stack (.VConstr index [])
  | .Case term arms => .Eval (.CaseScrutinee arms env :: stack) env term
  | .Builtin builtin => .Return stack (.VBuiltin builtin [] (expectedArgs builtin))
  | .Error => .Error

theorem step_evalTerm (sv : BuiltinSemanticsVariant) (stack : Stack) (env : Environment)
    (term : Term) : step sv (.Eval stack env term) = evalTerm stack env term := by
  cases term <;> rfl

/-- Expose just the value constructor when optimizing a symbolic force. -/
def forceValue (sv : BuiltinSemanticsVariant) (stack : Stack) : CekValue → State
  | .VDelay body env => .Eval stack env body
  | .VBuiltin b args (.More .ArgQ rest) => .Return stack (.VBuiltin b args rest)
  | .VBuiltin b args (.One .ArgQ) => evalBuiltin sv stack b args
  | _ => .Error

theorem step_forceValue (sv : BuiltinSemanticsVariant) (stack : Stack) (value : CekValue) :
    step sv (.Return (.ForceFrame :: stack) value) = forceValue sv stack value := by
  cases value with
  | VBuiltin b args expected =>
    cases expected with
    | More arg rest => cases arg <;> rfl
    | One arg => cases arg <;> rfl
  | _ => rfl

theorem runSteps_after_step (sv : BuiltinSemanticsVariant) (state next : State) (fuel : Nat)
    (transition : step sv state = next) :
    runSteps sv state (fuel + 1) = runSteps sv next fuel := by
  subst next
  cases state <;> cases fuel <;> rfl

theorem runSteps_halt (sv : BuiltinSemanticsVariant) (value : CekValue) (fuel : Nat) :
    runSteps sv (.Halt value) fuel = .Halt value := by
  cases fuel <;> rfl

theorem runSteps_error (sv : BuiltinSemanticsVariant) (fuel : Nat) :
    runSteps sv .Error fuel = .Error := by
  cases fuel <;> rfl

theorem runSteps_budgetExhausted (sv : BuiltinSemanticsVariant) (fuel : Nat) :
    runSteps sv .BudgetExhausted fuel = .BudgetExhausted := by
  cases fuel <;> rfl

/-- Rebuild the source term from consecutive application and force instructions.
`some arg` records an application, and `none` records a force. -/
def prefixTerm : List (Option Term) → Term → Term
  | [], term => term
  | some arg :: rest, term => .Apply (prefixTerm rest term) arg
  | none :: rest, term => .Force (prefixTerm rest term)

/-- Push the frames in the same order that CEK evaluates the prefix. -/
def prefixStack (env : Environment) : List (Option Term) → Stack → Stack
  | [], stack => stack
  | some arg :: rest, stack => prefixStack env rest (.LeftApplicationToTerm arg env :: stack)
  | none :: rest, stack => prefixStack env rest (.ForceFrame :: stack)

/-- No transition within the prefix can terminate or fail. At exactly its
length, the residual state is still an evaluation and therefore out of fuel. -/
theorem runSteps_evalPrefix (sv : BuiltinSemanticsVariant) (stack : Stack) (env : Environment)
    (instrs : List (Option Term)) (term : Term) (fuel : Nat) :
    runSteps sv (.Eval stack env (prefixTerm instrs term)) fuel =
      if fuel ≤ instrs.length then .BudgetExhausted
      else runSteps sv (.Eval (prefixStack env instrs stack) env term) (fuel - instrs.length) := by
  induction instrs generalizing stack fuel with
  | nil => cases fuel <;> rfl
  | cons instr rest ih =>
    cases fuel with
    | zero => rfl
    | succ fuel =>
      cases instr <;>
        simp only [prefixTerm, prefixStack, List.length_cons, Nat.succ_le_succ_iff,
          Nat.succ_sub_succ_eq_sub] <;>
        apply ih

/-- With enough fuel to enter the target, expose the residual run directly.
The equation also holds at the boundary where the remaining fuel is zero. -/
theorem runSteps_evalPrefix_advance (sv : BuiltinSemanticsVariant) (stack : Stack)
    (env : Environment) (instrs : List (Option Term)) (term : Term) (remaining : Nat) :
    runSteps sv (.Eval stack env (prefixTerm instrs term)) (instrs.length + remaining) =
      runSteps sv (.Eval (prefixStack env instrs stack) env term) remaining := by
  induction instrs generalizing stack with
  | nil => simp [prefixTerm, prefixStack]
  | cons instr rest ih =>
    cases instr <;>
      simp only [prefixTerm, prefixStack, List.length_cons, Nat.succ_add] <;>
      apply ih

/-- The native runner supplies a closed fuel comparison for a cut within the prefix. -/
theorem runSteps_evalPrefix_exhausted (sv : BuiltinSemanticsVariant) (stack : Stack)
    (env : Environment) (instrs : List (Option Term)) (term : Term) (fuel : Nat)
    (bound : decide (fuel ≤ instrs.length) = true) :
    runSteps sv (.Eval stack env (prefixTerm instrs term)) fuel = .BudgetExhausted := by
  rw [runSteps_evalPrefix, if_pos (of_decide_eq_true bound)]

end PlutusCore.UPLC.CekMachine.Blocks
