## Change

Linked issue: <!-- #123 -->

What changed, and why should it improve the benchmark?

## Upstream handoff

Select every repository that needs the winning change. Name the paths and linked upstream PRs, or write “pending.”

- [ ] `Lean-blaster` — paths / PR:
- [ ] `PlutusCoreBlaster` — paths / PR:
- [ ] `CardanoLedgerApiBlaster` — paths / PR:
- [ ] `Blaster-benchmarking` — paths / PR:

Upstream merge order, if any:

## Benchmark evidence

- Frozen cohort:
- Tier: smoke / clusters / full
- Baseline lab commit:
- This PR commit:
- Blaster / PlutusCore / Ledger API source commits or lab diff:
- Z3 version, SMT timeout, whole-process timeout, worker count:
- Runner and raw-result artifact link:

| Metric on the same cohort | Baseline | This PR | Change |
| --- | ---: | ---: | ---: |
| Independently verified replays | | | |
| Solver candidates awaiting replay | | | |
| Elaboration timeouts | | | |
| Optimization timeouts | | | |
| SMT timeouts | | | |
| Errors | | | |

List gained and regressed script hashes. State whether the comparison used the same machine or runner class.

## Replay evidence for any verified gain

- Concrete input fixture path:
- Ledger validity check and result:
- Independent CEK evaluator, budget, and result:
- Script hash and execution purpose:

Write “none; candidates only” when there is no independently replayed gain. A solver model alone must not raise the verified score.

## Checks

- [ ] The fixed smoke cohort ran with local lab dependencies.
- [ ] I attached raw results and described every regression.
- [ ] I claimed verified gains only for saved, independently replayed fixtures.
- [ ] I identified the upstream repository or repositories for this change.
