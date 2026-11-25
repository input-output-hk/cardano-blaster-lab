# Cardano `#prep_uplc` benchmark

`SellNFT.lean` measures the original CardanoLedgerApiBlaster `sellNFT` validator
at its checked-in 1,800 CEK steps with the same symbolic `spendingInputs`
conversion. The PlutusCore benchmark suite cannot import CardanoLedgerApi
without a dependency cycle, so this case lives in the lab benchmark, which
already depends on both packages.

From the lab root:

```sh
python3 scripts/bench_prep_uplc.py --z3 /path/to/z3
```

The runner builds its Lean dependencies in the CardanoLedgerApi package once
if needed, avoiding the unrelated Mathlib dependencies of the larger benchmark
workspace. It then invokes `lake lean` afresh, applies a 180-second wall limit,
and writes the harness JSONL plus build and Lean logs under `.tools/prep-uplc/`. The
JSONL `wall_ms` measures `#prep_uplc` itself; the runner also reports whole
process time. It keeps the case separate from the Cardano live-script smoke
suite so every PR does not pay this roughly 40-second preprocessing cost.

The case uses the existing baseline optimizer. PR #43's CEK block modes are
opt-in and require their registration module and command to be imported before
the measured `#prep_uplc` call; they are not silently enabled here.
