import Lean
import Blaster.Optimize.Env.ExprBuilder

open Lean Meta Blaster.Data.HashSet Blaster.Data.HashMap

namespace Blaster.Optimize

abbrev InstCache := HashMap InstKey Expr

inductive HashConsStack where
  | WaitAppFun (e a : Expr)
  | WaitAppArg (e f : Expr)
  | WaitForallType (e b : Expr)
  | WaitForallBody (e t : Expr)
  | WaitLambdaType (e b : Expr)
  | WaitLambdaBody (e t : Expr)
  | WaitLetType (e v b : Expr)
  | WaitLetValue (e t b : Expr)
  | WaitLetBody (e t v : Expr)
  | WaitMData (e : Expr)
  | WaitProjExpr (e : Expr)
deriving Repr

@[always_inline, inline]
def saveHashCons (old : Expr) (new : Expr) : TranslateEnvT Expr := do
  if exprEq old new then
    updateHashConsCache old
    return old
  else return new


private unsafe def hashconsAux (cur : Expr) (isResult : Bool) (stk : Array HashConsStack)
    (aliases : HashMap PtrExpr Expr) : TranslateEnvT Expr := do
  if isResult then
    if stk.usize > 0 then
      let topIdx := stk.usize - 1
      let next := stk.uget topIdx lcProof
      match next with
      | .WaitAppFun e a =>
           let stk := stk.uset topIdx (.WaitAppArg e cur) lcProof
           hashconsAux a false stk aliases
      | .WaitAppArg e f =>
           let r' ← saveHashCons e (← e.updateAppExpr! f cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
      | .WaitForallType e b =>
           let stk := stk.uset topIdx (.WaitForallBody e cur) lcProof
           hashconsAux b false stk aliases
      | .WaitForallBody e t =>
           let r' ← saveHashCons e (← e.updateForallExpr! t cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
      | .WaitLambdaType e b =>
           let stk := stk.uset topIdx (.WaitLambdaBody e cur) lcProof
           hashconsAux b false stk aliases
      | .WaitLambdaBody e t =>
           let r' ← saveHashCons e (← e.updateLambdaExpr! t cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
      | .WaitLetType e v b =>
           let stk := stk.uset topIdx (.WaitLetValue e cur b) lcProof
           hashconsAux v false stk aliases
      | .WaitLetValue e t b =>
           let stk := stk.uset topIdx (.WaitLetBody e t cur) lcProof
           hashconsAux b false stk aliases
      | .WaitLetBody e t v =>
           let r' ← saveHashCons e (← e.updateLetExpr! t v cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
      | .WaitMData e =>
           let r' ← saveHashCons e (← e.updateMDataExpr! cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
      | .WaitProjExpr e =>
           let r' ← saveHashCons e (← e.updateProjExpr! cur)
           let aliases := if exprEq e r' then aliases else aliases.insert e r'
           hashconsAux r' true stk.pop aliases
    else return cur
  else
    let cached := (← get).optEnv.hashConsCache.getD cur instCacheMiss
    if !exprEq cached.expr instCacheMiss then hashconsAux cached.expr true stk aliases
    else if let some shared := aliases.get? cur then hashconsAux shared true stk aliases
    else
       match cur with
       | .bvar .. | .mvar .. | .const .. | .fvar .. | .sort .. | .lit .. =>
           updateHashConsCache cur
           hashconsAux cur true stk aliases
       | .app f a =>
            let stk := stk.push (.WaitAppFun cur a)
            hashconsAux f false stk aliases
       | .letE _ t v b _ =>
            let stk := stk.push (.WaitLetType cur v b)
            hashconsAux t false stk aliases
       | .forallE _ t b _ =>
            let stk := stk.push (.WaitForallType cur b)
            hashconsAux t false stk aliases
       | .lam _ t b _ =>
            let stk := stk.push (.WaitLambdaType cur b)
            hashconsAux t false stk aliases
       | .mdata _ b =>
            let stk := stk.push (.WaitMData cur)
            hashconsAux b false stk aliases
       | .proj _ _ b =>
            let stk := stk.push (.WaitProjExpr cur)
            hashconsAux b false stk aliases

/-- Canonicalize a whole expression. The per-call map remembers the shared result
of rebuilding an original node, so another edge to that node can reuse it. -/
@[always_inline, inline]
def hashcons (e : Expr) : TranslateEnvT Expr :=
  unsafe hashconsAux e false (Array.emptyWithCapacity e.approxDepth.toNat) (HashMap.emptyWithCapacity 16)

@[always_inline, inline]
def getMVarAssignment! (mvar : Expr) : TranslateEnvT Expr := do
 match ← getExprMVarAssignment? mvar.mvarId! with
 | some v => hashcons v
 | none => throwEnvError "getMVarAssignment!: assignment expected for meta variable {reprStr mvar} !!!"

@[always_inline, inline]
def getMVarValue (mvar : Expr) : TranslateEnvT Expr := do
  let val := (← get).optEnv.mAssignments.getD mvar instCacheMiss
  if !exprEq val instCacheMiss then return val -- expr in mAssignments already hashcons
  else getMVarAssignment! mvar

@[always_inline, inline]
def getEnvMVarValue! (mvar : Expr) (mAssignments : MVarAssignments) : Expr :=
  let val := mAssignments.getD mvar instCacheMiss
  if !exprEq val instCacheMiss then val
  else panic! "getEnvMVarValue!: assignment expected for meta variable {reprStr mvar} !!!"

@[always_inline, inline]
def getEnvMVarValue' (mvar : Expr) (mAssignments : MVarAssignments) : Expr :=
  let val := mAssignments.getD mvar instCacheMiss
  if !exprEq val instCacheMiss then val -- expr in mAssignments already hashcons
  else mvar

@[always_inline, inline]
def getEnvMVarValue (mvar : Expr) : TranslateEnvT Expr :=
  return getEnvMVarValue' mvar (← get).optEnv.mAssignments

end Blaster.Optimize
