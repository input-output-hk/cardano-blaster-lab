import Blaster
import PlutusCore.UPLC.CekMachine.Blocks

open PlutusCore.UPLC.CekMachine
open PlutusCore.UPLC.Term (Program)

section Conditional

private def conditional : Program :=
  .Program (.Version 1 0 0) <|
    .Lam (.Apply (.Lam (.Var 0)) (.Force
      (.Apply (.Apply (.Apply (.Force (.Builtin .IfThenElse)) (.Var 0))
        (.Delay (.Const (.Integer 11)))) (.Delay (.Const (.Integer 13))))))

#index_uplc conditional

private def runConditional (b : Bool) (fuel : Nat) : State :=
  cekExecuteProgram conditional [.Const (.Bool b)] fuel

private def haltedInteger : State → Option Int
  | .Halt (.VCon (.Integer n)) => some n
  | _ => none

set_option warn.sorry false in
example : ∀ b, runConditional b 10 = .BudgetExhausted ∧
    runConditional b 28 = .BudgetExhausted ∧
    haltedInteger (runConditional b 29) = some (if b then 11 else 13) := by blaster

/--
info: ✅ Expected Falsified
---
info: Counterexample:
---
info:  - b: (false : Bool)
---
info: ✅ Replay: the instantiated Lean proposition evaluates to false
-/
#guard_msgs in
#blaster (solve-result: 1) (replay: 1) [∀ b, haltedInteger (runConditional b 29) = some 11]

example : haltedInteger (runConditional false 29) = some 13 := rfl

end Conditional

section BuiltinFailure

private def headOfEmptyList : Program :=
  .Program (.Version 1 0 0)
    (.Apply (.Force (.Builtin .HeadList)) (.Const (.ConstDataList [])))

#index_uplc headOfEmptyList

set_option warn.sorry false in
example : cekExecuteProgram headOfEmptyList [] 6 = .BudgetExhausted ∧
    cekExecuteProgram headOfEmptyList [] 7 = .Error := by blaster

end BuiltinFailure

section ReturnedClosure

private def closure : Program :=
  .Program (.Version 1 0 0) <|
    .Case (.Constr 0 [.Const (.Integer 41)])
      [.Lam (.Force (.Delay (.Lam (.Apply (.Var 0) (.Var 1)))))]

#index_uplc closure

set_option warn.sorry false in
example : cekExecuteProgram closure [] 12 =
    .Halt (.VLam (.Apply (.Var 0) (.Var 1)) [.VCon (.Integer 41)]) := by blaster

end ReturnedClosure
