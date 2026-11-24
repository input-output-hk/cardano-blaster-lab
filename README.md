# Cardano Blaster Lab

An integration workspace for improving Blaster against real Cardano scripts.
Agents can change the solver, UPLC evaluator, ledger context model, and
benchmark in one PR. Winning changes are then proposed to their upstream
repositories.

## Source trees

| Directory | Upstream | Starting ref |
| --- | --- | --- |
| `packages/Lean-blaster/` | `input-output-hk/Lean-blaster` | `blaster-extension` merged with `codex/libz3-typed-cex` |
| `packages/PlutusCoreBlaster/` | `input-output-hk/PlutusCoreBlaster` | `main` |
| `packages/CardanoLedgerApiBlaster/` | `input-output-hk/CardanoLedgerApiBlaster` | `main` |
| `benchmark/` | `input-output-hk/Blaster-benchmarking` | `codex/live-scripts-dashboard` |

Each source tree is imported as a Git subtree. The Lean-blaster tree merges the
Blaster extension with the native libz3 backend and typed counterexamples from
[Lean-blaster PR #480](https://github.com/input-output-hk/Lean-blaster/pull/480).
It retains the extension rules and supports `(replay: 1)` for Lean-side
counterexample checking. This replay is diagnostic; an independently validated
ledger context and CEK execution are still required for a verified benchmark
result. Exact source and integration commits are in
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
| Smoke | Every lab PR, one worker | Fixed 48-script sample across versions, purposes, and sizes |
| Clusters | Manual for promising PRs | One script per structural family |
| Full | Manual for finalists and release baselines | All 2,250 exact scripts |

The smoke and cluster passes are screening tools. Report headline coverage only
from a full run on the same frozen cohort and runner configuration as its
baseline. Worker count affects per-case latency and is part of the recorded
configuration. The hard timeout puts an upper bound of roughly 20 minutes of
case time on the one-worker PR smoke check. At four workers, the corresponding
case-time bounds are five minutes for smoke, 1.7 hours for clusters, and 3.9
hours for full; build time and runner overhead are additional. GitHub Actions
caches the compiled shared packages across runs. Escalate only changes that show
a useful signal on the cheaper pass, and inspect regressions before the next
tier. A hosted full run reuses cached cluster results from the same commit and
configuration when available, so those cases do not run twice.

The standard hosted runner needs one script worker: a four-worker run timed out
on 47 of 48 cases during elaboration, while a one-worker pilot reached Blaster
on both tested cases. See the [four-worker run](https://github.com/input-output-hk/cardano-blaster-lab/actions/runs/45226647701)
and [one-worker pilot](https://github.com/input-output-hk/cardano-blaster-lab/actions/runs/45230525215).
Use a calibrated machine for cluster and full sweeps; only compare results from
the same hardware class, worker count, timeout, cohort, and source revisions.
The hosted manual heavy tiers are available for experiments, but the standard
runner's 300-minute job cap can end a one-worker full sweep early.

Run locally after installing Lean 4.24 and Z3 5.4 or newer with its C headers
and library. The `--z3` path must belong to that installation:

```sh
python3 scripts/bench.py smoke --z3 /path/to/z3
python3 scripts/bench.py clusters --z3 /path/to/z3
python3 scripts/bench.py full --z3 /path/to/z3
```

For an affected script, run `python3 LiveScripts/benchmark.py --script HASH
--z3 /path/to/z3` from `benchmark/`. For a local heavy sweep, add `--limit 100`
and repeat the command on the same checkout. The runner skips cases already
recorded with the same configuration, so each chunk advances the sweep.

See `benchmark/LiveScripts/README.md` for corpus and result semantics. The
[public Cardano Scripts dashboard](https://input-output-hk.github.io/cardano-blaster-lab/)
is built from `benchmark/cardano-dashboard/`. Its grid reads the committed
`benchmark/LiveScripts/results/latest.json` snapshot selected by
`active-config.json`. A push to `main` that changes those files redeploys the
site through GitHub Pages.

The benchmark workflow now checks typed counterexamples from its own run with
the independent ledger-context, Plutus data round-trip, and CEK replay guards.
It uploads new witnesses and `verified.json` as an artifact; a solver candidate
that fails a guard stays a candidate. An open lab PR gets a hollow point on the
frontier graph when its current head has more verified scripts than the
published best for the same frozen cohort. Select the point to see the PR and
replay check. The green line follows published results. Completed benchmarks,
new PR commits, and closures refresh the open-PR points.

## Sending a lab PR upstream

The **Upstream handoff** GitHub Action lets a lab repository admin comment
`/upstream` on an open lab PR. It splits that PR's commits by the source paths
in [`upstreams.json`](upstreams.json), replays each affected subtree onto its
configured upstream branch, and opens draft PRs in the affected repositories.
Each mirrored commit keeps its original author, author date, message, and
`Co-authored-by` trailers. The GitHub App bot is the committer and PR opener.
The action comments with the draft links or a conflict diagnostic on the lab
PR. Repeating `/upstream` for the same PR head finds the existing drafts; a new
PR head gets new draft branches. Merge commits in the source PR require manual
splitting.

To enable the action after its workflow is merged into the default branch:

1. Create a GitHub App with **Contents: Read and write** and **Pull requests:
   Read and write** repository permissions. Install it on `Lean-blaster`,
   `PlutusCoreBlaster`, `CardanoLedgerApiBlaster`, `Blaster-benchmarking`,
   and `cardano-blaster-lab` in `input-output-hk`. The lab installation lets
   the bot post draft links back to the source PR. No webhook or HTTPS callback
   is needed.
2. In `cardano-blaster-lab` → **Settings → Secrets and variables → Actions**,
   set the repository **variable** `UPSTREAM_APP_CLIENT_ID` to the App's client
   ID and the repository **secret** `UPSTREAM_APP_PRIVATE_KEY` to its generated
   private key (including the PEM header and footer).
3. As a repository admin, comment exactly `/upstream` on the lab PR. Review
   the draft upstream PRs and their CI before merging them.

The workflow checks admin permission before minting App tokens. It runs code
from the lab's default branch; PR contents are read as Git patches and are not
executed with a write token. One App token is limited to the four upstream
repositories for commits and draft PRs; a second is limited to the lab
repository for posting the result comment.

## Automatic error reports

After each benchmark workflow, the [error agent](scripts/error_agent.py) reads
the raw result artifact and files one `benchmark-error` issue per script with
status `error`. It includes the exact diagnostic, generated Lean sources,
corpus and transaction metadata, source revision, configuration, and a replay
command. A later sighting adds evidence to the same issue. The workflow can
also be dispatched manually with a benchmark Actions run ID.

The reporter works without an OpenAI key. To add a bounded model analysis of
up to 20 distinct errors per run, set the repository Actions secret
`OPENAI_API_KEY`; the default model is `gpt-6.2-sol`. To notify a Slack channel
when new or reopened issues appear, create an incoming webhook for that channel
and set the repository Actions secret `SLACK_WEBHOOK_URL`. The agent sends one
digest per run, and repeat sightings do not alert again. Create both secrets
under **Settings → Secrets and variables → Actions → Secrets → New repository
secret**; do not use the **Variables** tab or put keys in an issue, PR, or
tracked file. The webhook remains tied to the selected Slack channel. After
adding an OpenAI key, manually rerun **Report Cardano script
errors** with the original benchmark run ID and `refresh_analysis=true` to
enrich an existing issue without duplicating its report. Set `test_slack=true`
on a manual run to send a connection check to the configured channel.
