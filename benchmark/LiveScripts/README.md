# Live Cardano scripts

`LiveScripts/` is an additive corpus of Plutus scripts executed on Cardano
mainnet or preprod. The initial `2026-11-23` cohort is a completed seven-day
execution backfill: 2,257 network records, 2,250 distinct script hashes, and
2,030 shared transaction fixtures. It includes old scripts that executed in
the window, not only scripts first published in that window.

Each `S_<hash>/` directory contains the original script CBOR, a `Script.lean`
import through PlutusCoreBlaster, one `Properties.lean` search, and metadata.
`catalog.json` indexes all imported scripts. `cohorts/*.json` freeze script
hash sets so later benchmark runs use a stable denominator. `fixtures/` holds
observed transaction CBOR and metadata for study and regression tests. Exact
script hashes are deduplicated across networks. Similar scripts retain their
own directories and share a structural `cluster_id` only for exploration.

## Property and score

The Lean property asks Blaster for a successful CEK execution under the
version-specific `CardanoLedgerApi` validity predicate for one observed
script purpose. It uses CEK fuel 1000 and a 10-second SMT limit. Scripts
observed at several purposes currently search the first of spending, minting,
rewarding, or certifying; `search_purpose` records the selection in metadata.
Falsification produces a **candidate** model, not a verified script context.
The model must be materialized as concrete Plutus data and independently
replayed through the evaluator and ledger checks. On-chain examples prove
those scripts executed in their recorded transactions; they are fixtures,
not Blaster discoveries.
The earlier SMTLIB V3 pilot printed a two-field `Constr 0` for a
`ScriptContext`; the ledger API decoder rejected it. Native Z3 typed-model
reconstruction now produces replayable context values for most candidates.

The dashboard turns a script green only after an independently built replay
module checks the concrete Blaster witness against the version-specific ledger
API context predicate, an `IsData` encode/decode round trip, and CEK success at
the fuel recorded in its witness provenance. This checks the Lean ledger API
model; it does not claim that an actual transaction containing the generated
context was submitted on-chain.
Timeout or unknown results do not mean a script is unsatisfiable. In the frozen
seven-day baseline, 239 runs reported `Unexpected Valid` at CEK fuel 1000.
They are marked unknown because a higher fuel limit may change the outcome;
the 24 remaining errors are actual Lean or SMT failures.

The bounded native-model sweep verified 50 of the 52 baseline candidates:
25 V3 and 25 V2. The two remaining V2 candidate models pass the context and
data checks but evaluate to CEK `Error` at both fuel 1000 and 10000. Their
`CandidateWitness.lean` files preserve the models for investigation. The V2
replays also uncovered and fixed a `TxOutRef` `IsData` decoder mismatch.
One additional 604-byte V2 script reported `Unexpected Valid` at fuel 1000,
then produced a candidate at fuel 10000. Its concrete replay passed at fuel
10000, giving 51 verified scripts. This higher-fuel result is recorded as a
separate frontier event so its changed search bound remains visible.

A bounded fuel-5000 pilot revisited eight scripts previously reported unknown
at fuel 1000. One 883-byte V1 script produced a candidate after 170 seconds;
its typed context passed the ledger validity, data round-trip, and CEK replay
checks at fuel 5000. The other seven hit a 180-second wall limit, including a
265-byte V2 script. The local timings and selected hashes are in
`results/fuel5000-pilot-20261124.json`. This pilot does not imply that the
seven timed-out scripts lack valid contexts.

The first verified V3 witness is
`S_186e32faa80a26810392fda6d559c7ed4721a65ce1c9d4ef3e1c87b4/ReplayWitness.lean`.
It came from a fresh native Z3 run of the same property with
`(backend: ffi) (replay: 1)` on monorepo revision
`90a10093c20c8b82d7abd317cba27453441fb182`. Blaster's internal proposition
replay remained inconclusive, but the separate concrete evaluator passed all
three checks. The original seven-day baseline classified the same script as a
candidate; the typed witness was produced after the libz3 merge.

To add a replay, save the typed model as `ReplayWitness.lean` in the script
directory. Define `replayContext : ScriptContext` for V3 or
`replayInput : <Purpose>Input` for V1/V2. Then run:

```sh
cd benchmark
python3 LiveScripts/verify_replays.py
python3 LiveScripts/verify_replays.py --check
```

For a baseline candidate, the bounded materializer runs the same property
through native Z3, saves the typed model, and invokes the replay verifier:

```sh
python3 LiveScripts/materialize_replays.py --hash <script-hash> --cek-fuel 10000 --wall-timeout 90
```

The verifier generates a temporary Lean module containing the three mandatory
checks and publishes only passing witnesses in `results/verified.json`. CI
rebuilds every witness and checks the committed result before a PR can pass.
The dashboard's script detail links to these typed context records (and to
`CandidateWitness.lean` for the two failed replays). Genuine Lean/SMT failures
have compact reports under `results/errors/`; the detail shows the message and
links to the full report.

## Import and run

The importer accepts a completed local `BlasterCorpus` export with
`manifest.jsonl`, `scripts/`, and `transactions/`. It recomputes the Cardano
script hash from the language tag and CBOR, checks sizes and identities, and
preserves prior cases when the rolling window changes.

```sh
python3 LiveScripts/import_corpus.py --corpus /path/to/recent-export --cohort YYYY-MM-DD
python3 -m unittest discover -s LiveScripts -p 'test_*.py'
lake build LiveScripts.S_<hash>.Script
python3 LiveScripts/run_all.py --workers 4 --z3 /path/to/z3 --timeout 25
python3 cardano-dashboard/build.py
```

The search runner requires Z3 5.4 or newer. The 10-second Blaster setting
limits only SMT solving; the runner also kills the whole Lean process group
after 25 wall-clock seconds, including elaboration and optimization. It writes
raw results under `results/` and classifies which stage timed out.
`--cluster-first` tries the smallest member of each structural family before
the full exact-hash sweep. Cluster diagnostics can resume with
`--skip-existing`; a full run reruns every exact hash so its raw artifact
contains every candidate model. `results/latest.json` feeds
candidate, timeout, unknown, and error states to the dashboard. A benchmark
run does not automatically produce a green result or a frontier point.
`run_all.py` performs both passes in sequence and resumes completed cases.
PR smoke checks replay every new candidate. A completed full GitHub Actions
sweep starts a separate matrix workflow that replays every new candidate in
batches of up to 16 and checks that every candidate was attempted before
uploading the combined evidence artifact. It builds the shared Lean
dependencies once, then passes that build artifact to every replay batch.
To rerun only the replay from an existing complete full-sweep artifact,
including a run whose post-search replay step failed, use the Actions **Replay every full-sweep
candidate** workflow's **Run workflow** button and enter the benchmark run ID,
or run:

```sh
gh workflow run full-replay.yml -R input-output-hk/cardano-blaster-lab -f source_run_id=RUN_ID
```

The replay jobs restore the shared Lean build cache and download the exact
candidate models from that benchmark run. The completed replay artifact
contains every attempted outcome and all newly verified witnesses.

### Compare CEK block runners

From the lab root, use the same worker count and limits for each arm.

```sh
for mode in baseline generated indexed; do
  python3 scripts/bench.py smoke --z3 /path/to/z3 --workers 1 --cek-blocks "$mode"
done
```

The comparison elaborates the existing properties in temporary files.
`baseline` uses the ordinary Blaster runner. `generated` enables blocks
generated from the CEK step equations. `indexed` enables the same runner
with a program-counter table for the imported script. The script, property,
fuel, and solver settings are shared by all three modes. Raw results,
including phase timings from Blaster, go under `results/cek-blocks/<mode>/`.
The usual corpus command continues to write the dashboard's result files.

## Contributing

PRs can improve the context generator, symbolic execution, replay, or ledger
checks. Run comparisons against a frozen cohort. A public frontier event
should identify the PR, its exact verified script hashes, and the replay and
context-validation evidence. Pinned events can annotate the progress curve.
Events may use `prs: [{"repo": "Lean-blaster", "number": 123, "url": "..."}]`
to link one or more upstream PRs across Lean-blaster, PlutusCoreBlaster, and
CardanoLedgerApiBlaster. The older single `pr_url` field remains supported.
The source dashboard is in `cardano-dashboard/` and builds to its ignored
`dist/` directory.
