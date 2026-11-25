import Blaster.Optimize.Env.Extension
import PlutusCore.UPLC.CekMachine

namespace PlutusCore.UPLC.CekMachine.Blocks

open Lean Elab Command Meta Blaster.Optimize
open Lean.Parser.Term (doSeqItem)
open PlutusCore.UPLC.CekMachine
open PlutusCore.UPLC.Builtins (expectedArgs)
open PlutusCore.UPLC.CekValue (CekValue)
open PlutusCore.UPLC.Term (BuiltinFun)

private def lookupCEKBinding? (env : Expr) (index : Nat) : Option (Option Expr) :=
  match env with
  | .app (.const ``List.nil _) _ => some none
  | .app (.app (.app (.const ``List.cons _) _) value) tail =>
    match index with
    | 0 => some (some value)
    | index + 1 => lookupCEKBinding? tail index
  | _ => none

abbrev BuiltinArityIndex := NameMap Expr
private abbrev Transition := BuiltinArityIndex → Expr → Expr → Expr → Expr → Option Expr
abbrev StepEquationIndex := NameMap Transition

private def headName (e : Expr) : Name :=
  match e.getAppFn with
  | .const name _ => name
  | _ => .anonymous

/-- Share state and stack decomposition between rule generation and dispatch.
The final three operands carry the fields still visible to the equation. -/
@[inline] private def withStepOperands (state : Expr)
    (dispatch : Name → Nat → Expr → Expr → Expr → Option α) : Option α :=
  match state with
  | .app (.app (.app (.const ``State.Eval []) stack) env) term =>
    dispatch (headName term) 3 stack env term
  | .app (.app (.const ``State.Return []) stack) value =>
    match stack with
    | .app (.app (.app (.const ``List.cons [.zero]) (.const ``Frame [])) frame) rest =>
      dispatch (headName frame) 3 frame rest value
    | .app (.const ``List.nil [.zero]) (.const ``Frame []) =>
      dispatch ``List.nil 1 value state state
    | _ => none
  | .app (.const ``State.Halt []) value => dispatch ``State.Halt 1 value state state
  | .const ``State.Error [] => dispatch ``State.Error 0 state state state
  | .const ``State.BudgetExhausted [] => dispatch ``State.BudgetExhausted 0 state state state
  | _ => none

private def builtinArity (arities : BuiltinArityIndex) (builtin : Expr) : Expr := Id.run do
  if let .const name _ := builtin then
    if let some arity := arities.find? name then return arity
  return mkApp (mkConst ``expectedArgs) builtin

private def quoteLevel : Level → MetaM Term
  | .zero => `(Level.zero)
  | .succ level => do `(Level.succ $(← quoteLevel level))
  | .max left right => do `(Level.max $(← quoteLevel left) $(← quoteLevel right))
  | .imax left right => do `(Level.imax $(← quoteLevel left) $(← quoteLevel right))
  | level => throwError "unsupported universe in a CEK equation: {level}"

private def quoteLevels (levels : List Level) : MetaM Term := do
  let levels ← levels.toArray.mapM quoteLevel
  `([$levels,*])

private def quoteBinderInfo : BinderInfo → MetaM Term
  | .default => `(BinderInfo.default)
  | .implicit => `(BinderInfo.implicit)
  | .strictImplicit => `(BinderInfo.strictImplicit)
  | .instImplicit => `(BinderInfo.instImplicit)

private abbrev Bindings := FVarIdMap Ident

/-- Compile the equation's RHS to a constructor expression with the matched
operands substituted for its binders. -/
private partial def buildExpr (arities : Ident) (bindings : Bindings) (e : Expr) : MetaM Term := do
  let build := buildExpr arities bindings
  match e with
  | .fvar id =>
    let some var := bindings.get? id | throwError "unbound CEK equation variable: {e}"
    return var
  | .app (.const ``expectedArgs _) builtin => `(builtinArity $arities $(← build builtin))
  | .app f a => `(mkApp $(← build f) $(← build a))
  | .const name levels => `(mkConst $(quote name) $(← quoteLevels levels))
  | .lit (.natVal n) => `(mkNatLit $(quote n))
  | .lit (.strVal s) => `(mkStrLit $(quote s))
  | .bvar i => `(Expr.bvar $(quote i))
  | .sort level => `(Expr.sort $(← quoteLevel level))
  | .lam name type body info =>
    `(Expr.lam $(quote name) $(← build type) $(← build body) $(← quoteBinderInfo info))
  | .forallE name type body info =>
    `(Expr.forallE $(quote name) $(← build type) $(← build body) $(← quoteBinderInfo info))
  | .letE name type value body nondep =>
    `(Expr.letE $(quote name) $(← build type) $(← build value) $(← build body) $(quote nondep))
  | .proj name index value => `(Expr.proj $(quote name) $(quote index) $(← build value))
  | .mdata _ value => build value
  | _ => throwError "unsupported CEK equation expression: {e}"

private structure PatternState where
  bindings : Bindings := {}
  tests : Array Term := #[]

private abbrev PatternM := StateT PatternState MetaM

private def freshPattern (stem : Name) : PatternM Ident := do
  return mkIdent (← mkFreshUserName stem)

private partial def buildPattern (e : Expr) : PatternM Term := do
  match e with
  | .app f a => `(Expr.app $(← buildPattern f) $(← buildPattern a))
  | .fvar id =>
    let v ← freshPattern `operand
    if let some previous := (← get).bindings.get? id then
      let test ← `(Expr.eqv $previous $v)
      modify fun (state : PatternState) => { state with tests := state.tests.push test }
    else
      modify fun (state : PatternState) => { state with bindings := state.bindings.insert id v }
    return v
  | .const name levels =>
    let n ← freshPattern `ctor
    let ls ← freshPattern `levels
    let levels ← liftM (quoteLevels levels)
    let test ← `($n == $(quote name) && $ls == $levels)
    modify fun state => { state with tests := state.tests.push test }
    `(Expr.const $n $ls)
  | _ => throwError "unsupported CEK equation pattern: {e}"

/-- Negative matching premises require a definite constructor conflict. An
unknown expression or a wildcard is insufficient to discharge a premise. -/
private partial def constructorConflict (subject : Term) (pattern : Expr) : MetaM Term := do
  if pattern.isFVar then return ← `(false)
  let .const name _ := pattern.getAppFn
    | throwError "expected a constructor pattern in a CEK exclusion: {pattern}"
  let .ctorInfo ctor ← getConstInfo name
    | throwError "expected a constructor in a CEK exclusion: {name}"
  let ctors : Array Term := (← getConstInfoInduct ctor.induct).ctors.toArray.map quote
  let args := mkIdent (← mkFreshUserName `fields)
  let mut test ← `(false)
  for i in [ctor.numParams:pattern.getAppNumArgs] do
    let field ← `($args[$(quote i)]!)
    let conflict ← constructorConflict field pattern.getAppArgs[i]!
    test ← `($test || $conflict)
  let actual := mkIdent (← mkFreshUserName `actual)
  `(let $actual := headName $subject
    if $actual == $(quote name) then
      let $args := ($subject).getAppArgs
      ($args).size == $(quote pattern.getAppNumArgs) && $test
    else (#[$ctors,*]).contains $actual)

private def buildExclusion (bindings : Bindings) (premise : Expr) : MetaM Term := do
  forallTelescope premise fun vars conclusion => do
    let some equality := vars.back? | throwError "empty CEK exclusion: {premise}"
    let some (_, .fvar subject, pattern) := eq? (← inferType equality)
      | throwError "unsupported CEK exclusion premise: {premise}"
    unless conclusion.isConstOf ``False do throwError "expected a CEK exclusion: {premise}"
    let some operand := bindings.get? subject | throwError "unbound CEK exclusion subject"
    constructorConflict operand pattern

/-- Derive the two branches of a lookup match from Lean's matcher. A literal
index can be resolved by walking the visible environment constructors. -/
private def buildResult (arities : Ident) (bindings : Bindings) (rhs : Expr) : MetaM Term := do
  let fallback ← `(some $(← buildExpr arities bindings rhs))
  let some info ← getMatcherInfo? (headName rhs) | return fallback
  unless info.numDiscrs == 1 do return fallback
  let args := rhs.getAppArgs
  let pos := info.getFirstDiscrPos
  let #[type, env, index] := args[pos]!.getAppArgs | return fallback
  let .const ``List.get?Internal [level] := args[pos]!.getAppFn | return fallback
  withLocalDeclD `lookupValue type fun value => do
    let someValue := mkApp2 (mkConst ``Option.some [level]) type value
    let noneValue := mkApp (mkConst ``Option.none [level]) type
    let yes ← whnf (mkAppN rhs.getAppFn (args.set! pos someValue))
    let no ← whnf (mkAppN rhs.getAppFn (args.set! pos noneValue))
    let v := mkIdent (← mkFreshUserName `value)
    let yes ← buildExpr arities (bindings.insert value.fvarId! v) yes
    let no ← buildExpr arities bindings no
    let env ← buildExpr arities bindings env
    let index ← buildExpr arities bindings index
    `(match ($index) with
      | Expr.lit (.natVal i) =>
        match lookupCEKBinding? $env i with
        | some (some $v) => some $yes
        | some none => some $no
        | none => $fallback
      | _ => $fallback)

private def compileEquation (eqn : Name) : MetaM (Name × Term) := do
  forallTelescope (← getConstInfo eqn).type fun vars conclusion => do
    let some (_, lhs, rhs) := eq? conclusion | throwError "not an equation: {eqn}"
    let #[.fvar sv, sigma] := lhs.getAppArgs | throwError "unexpected CEK equation: {eqn}"
    let some (key, operands) := withStepOperands sigma (fun key count a b c =>
        some (key, (#[a, b, c].toList.take count).toArray))
      | throwError "unindexed CEK equation: {eqn}"
    if key.isAnonymous then throwError "unindexed CEK equation: {eqn}"
    let arities := mkIdent (← mkFreshUserName `arities)
    let svArg := mkIdent (← mkFreshUserName `semantics)
    let args ← (#[`first, `second, `third] : Array Name).mapM fun n => do
      return mkIdent (← mkFreshUserName n)
    let first := args[0]!
    let second := args[1]!
    let third := args[2]!
    let (patterns, state) ← (operands.mapM buildPattern).run { bindings := ({} : Bindings).insert sv svArg }
    let clauses ← patterns.mapIdxM fun i pattern => do
      let arg := args[i]!
      if pattern.raw.isIdent then
        let name : Ident := ⟨pattern.raw⟩
        `(doSeqItem| let $name:ident := $arg)
      else
        `(doSeqItem| let $pattern := $arg | none)
    let mut tests := state.tests
    for var in vars do
      let type ← inferType var
      if ← isProp type then
        tests := tests.push (← buildExclusion state.bindings type)
    let mut check ← `(true)
    for test in tests.reverse do
      check ← `($test && $check)
    let rhs ← buildResult arities state.bindings rhs
    let fn ← `(fun $arities $svArg $first $second $third => do
      $clauses:doSeqItem*
      guard $check
      let some next := $rhs | none
      return next)
    return (key, fn)

/-- Compile each bucket as a series of direct calls with a shared operand
prefix. Candidate order remains the order of the source equations. -/
private def compileBucket (rules : Array Term) : MetaM Term := do
  let arities := mkIdent (← mkFreshUserName `arities)
  let sv := mkIdent (← mkFreshUserName `semantics)
  let first := mkIdent (← mkFreshUserName `first)
  let second := mkIdent (← mkFreshUserName `second)
  let third := mkIdent (← mkFreshUserName `third)
  let mut body ← `(none)
  for rule in rules.reverse do
    body ← `(($rule) $arities $sv $first $second $third <|> $body)
  `(fun $arities $sv $first $second $third => $body)

local elab "declare_cek_equations" : command => do
  let equations ← liftTermElabM do
    let some eqns ← getEqnsFor? ``step | throwError "missing CEK step equations"
    eqns.mapM fun eqn => liftM (compileEquation eqn)
  let buckets := equations.foldl (fun (buckets : NameMap (Array Term)) (key, rule) =>
    buckets.insert key ((buckets.find? key).getD #[] |>.push rule)) {}
  let entries ← liftTermElabM <| buckets.toList.toArray.mapM fun (key, rules) => do
    `(($(quote key), ($(← compileBucket rules) : Transition)))
  let name := mkIdent `stepEquations
  elabCommand (← `(def $name : StepEquationIndex :=
    Array.foldl (fun index (key, rule) => index.insert key rule) {} #[$entries,*]))

declare_cek_equations

private def quoteConstructor : Expr → CommandElabM (TSyntax `term)
  | .const name [] => `(mkConst $(quote name))
  | .app f a => do `(mkApp $(← quoteConstructor f) $(← quoteConstructor a))
  | e => throwError "unexpected builtin arity expression {e}"

/-- Compile each closed `expectedArgs` computation to constructor expressions. -/
local elab "declare_cek_arity_index" : command => do
  let builtins ← getConstInfoInduct ``BuiltinFun
  let entries ← builtins.ctors.toArray.mapM fun builtin => do
    let args ← liftTermElabM <| Lean.Meta.reduce (mkApp (mkConst ``expectedArgs) (mkConst builtin))
    `(($(quote builtin), $(← quoteConstructor args)))
  let index := mkIdent `cekArityIndex
  elabCommand (← `(def $index : BuiltinArityIndex :=
    Array.foldl (fun index (name, args) => index.insert name args) {} #[$entries,*]))

declare_cek_arity_index

/-- Try the compiled equations for one transition. -/
def generatedCEKStep (arities : BuiltinArityIndex) (sv state : Expr) : Option Expr := do
  if sv.hasLooseBVars || state.hasLooseBVars then none else
    withStepOperands state fun key _ first second third => do
      let rule ← stepEquations.find? key
      rule arities sv first second third

end PlutusCore.UPLC.CekMachine.Blocks
