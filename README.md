# Cardano Blaster Lab

An integration workspace for improving Blaster against real Cardano scripts.
Agents can change the solver, UPLC evaluator, ledger context model, and
benchmark in one PR. Winning changes are then proposed to their upstream
repositories.

## Source trees

| Directory | Upstream | Starting ref |
| --- | --- | --- |
| `packages/Lean-blaster/` | `input-output-hk/Lean-blaster` | `blaster-extension` |
| `packages/PlutusCoreBlaster/` | `input-output-hk/PlutusCoreBlaster` | `main` |
| `packages/CardanoLedgerApiBlaster/` | `input-output-hk/CardanoLedgerApiBlaster` | `main` |
| `benchmark/` | `input-output-hk/Blaster-benchmarking` | `codex/live-scripts-dashboard` |

Each source tree is imported as a Git subtree. Exact starting commits are in
[`upstreams.json`](upstreams.json). The Lake dependencies inside the lab point
to these local trees, so an agent's changes are tested together. Upstream
repositories remain the release source; a lab PR records which of them need a
follow-up PR.

## Benchmark tiers

The fixed seven-day cohort contains 2,250 exact scripts. The PR check runs a
small, stratified smoke cohort. The cluster pass tries one representative per
structural family. The full pass runs every exact hash. Every case has a
10-second SMT limit and a separate 25-second whole-process limit. A solver
counterexample is a *candidate* until it yields a concrete context that passes
independent ledger and CEK replay.

| Tier | When | Scope |
| --- | --- | --- |
| Smoke | Every lab PR | Fixed 48-script sample across versions, purposes, and sizes |
| Clusters | Manual for promising PRs | One script per structural family |
| Full | Manual for finalists and release baselines | All 2,250 exact scripts |

The smoke and cluster passes are screening tools. Report headline coverage only
from a full run on the same frozen cohort and runner configuration as its
baseline. The hard timeout puts an upper bound of roughly five minutes of case
time on smoke, 1.7 hours on clusters, and 3.9 hours on full at four workers;
build time and runner overhead are additional. Escalate only changes that show
a useful signal on the cheaper pass, and inspect regressions before the next
tier. To test one affected script, use `python3 LiveScripts/benchmark.py
--script HASH --z3 /path/to/z3` from `benchmark/`.

Run locally after installing Lean 4.24 and Z3 5.4 or newer:

```sh
python3 scripts/bench.py smoke --z3 /path/to/z3
python3 scripts/bench.py clusters --z3 /path/to/z3
python3 scripts/bench.py full --z3 /path/to/z3
```

See `benchmark/LiveScripts/README.md` for corpus and result semantics. The
public dashboard source is `benchmark/cardano-dashboard/`.
