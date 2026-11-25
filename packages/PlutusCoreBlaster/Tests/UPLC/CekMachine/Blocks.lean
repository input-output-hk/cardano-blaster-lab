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

set_option warn.sorry false in
example : ∀ fuel, runSteps default .Error fuel = .Error ∧
    runSteps default .BudgetExhausted fuel = .BudgetExhausted ∧
    runSteps default (.Halt (.VCon .Unit)) fuel = .Halt (.VCon .Unit) := by blaster

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

section BuiltinChoice

open PlutusCore.Data (Data)
open PlutusCore.UPLC.CekValue (CekValue)
open PlutusCore.UPLC.Term (Const)

#cek_blocks

private def chooseListState (arg : CekValue) : State :=
  .Return
    [.RightApplicationOfValue
      (.VBuiltin .ChooseList [.VDelay (.Const (.Integer 11)) [], arg] (.One .ArgV)),
      .ForceFrame]
    (.VDelay (.Const (.Integer 13)) [])

set_option warn.sorry false in
example : ∀ items : List Data,
    runSteps default (chooseListState (.VCon (.ConstDataList items))) 1 = .BudgetExhausted ∧
    runSteps default (chooseListState (.VCon (.ConstDataList items))) 3 = .BudgetExhausted ∧
    haltedInteger (runSteps default (chooseListState (.VCon (.ConstDataList items))) 4) =
      some (if items.isEmpty then 11 else 13) := by blaster

set_option warn.sorry false in
example : runSteps default (chooseListState (.VCon (.Integer 7))) 0 = .BudgetExhausted ∧
    runSteps default (chooseListState (.VCon (.Integer 7))) 1 = .Error := by blaster

set_option warn.sorry false in
example : ∀ (constants : List Const) (pairs : List (Data × Data)),
    haltedInteger (runSteps default (chooseListState (.VCon (.ConstList constants))) 4) =
      some (if constants.isEmpty then 11 else 13) ∧
    haltedInteger (runSteps default (chooseListState (.VCon (.ConstPairDataList pairs))) 4) =
      some (if pairs.isEmpty then 11 else 13) := by blaster

end BuiltinChoice

section StrictChoiceArguments

open PlutusCore.UPLC.Term (Term)

private def divideByZero : Term :=
  .Apply (.Apply (.Builtin .DivideInteger) (.Const (.Integer 1))) (.Const (.Integer 0))

private def strictChoice : Program :=
  .Program (.Version 1 0 0) <|
    .Apply (.Apply (.Apply (.Force (.Builtin .IfThenElse)) (.Const (.Bool true)))
      (.Const (.Integer 1))) divideByZero

example : cekExecuteProgram strictChoice [] 100 = .Error := rfl

#index_uplc strictChoice

set_option warn.sorry false in
example : cekExecuteProgram strictChoice [] 100 = .Error := by blaster

end StrictChoiceArguments

section ConstructorBuiltins

open PlutusCore.Data (Data)
open PlutusCore.Integer (Integer)
open PlutusCore.UPLC.CekMachine
open PlutusCore.UPLC.CekValue (CekValue)
open PlutusCore.UPLC.Term (BuiltinFun Const)

#cek_blocks

private def builtinWithFinalArgument (builtin : BuiltinFun) (arg : Const) : State :=
  .Return [.RightApplicationOfValue (.VBuiltin builtin [] (.One .ArgV))] (.VCon arg)

set_option warn.sorry false in
example : ∀ (tag : Integer) (fields : List Data),
    runSteps default (builtinWithFinalArgument .UnConstrData (.Data (.Constr tag fields))) 1 =
      .BudgetExhausted ∧
    runSteps default (builtinWithFinalArgument .UnConstrData (.Data (.Constr tag fields))) 2 =
      .Halt (.VCon (.Pair (.Integer tag, .ConstDataList fields))) := by blaster

set_option warn.sorry false in
example : ∀ (fields : List Data),
    runSteps default (builtinWithFinalArgument .UnConstrData (.Data (.List fields))) 0 =
      .BudgetExhausted ∧
    runSteps default (builtinWithFinalArgument .UnConstrData (.Data (.List fields))) 1 =
      .Error ∧
    runSteps default (builtinWithFinalArgument .HeadList (.ConstDataList [])) 1 =
      .Error := by blaster

set_option warn.sorry false in
example : ∀ (item : Data) (tail : List Data) (const : Const) (consts : List Const)
    (pair : Data × Data) (pairs : List (Data × Data)),
    runSteps default (builtinWithFinalArgument .HeadList (.ConstDataList (item :: tail))) 2 =
      .Halt (.VCon (.Data item)) ∧
    runSteps default (builtinWithFinalArgument .HeadList (.ConstList (const :: consts))) 2 =
      .Halt (.VCon const) ∧
    runSteps default (builtinWithFinalArgument .HeadList (.ConstPairDataList (pair :: pairs))) 2 =
      .Halt (.VCon (.PairData pair)) := by blaster

end ConstructorBuiltins
