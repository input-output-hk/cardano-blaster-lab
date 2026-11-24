#!/usr/bin/env python3
"""Replay typed counterexamples from the exact benchmark run that found them."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

from materialize_replays import ROOT, save_witness, typed_model, witness_type
from verify_replays import OUTPUT


HASH = re.compile(r"[0-9a-f]{56}\Z")


def replay(results_file: Path, limit: int, cek_fuel: int, head_sha: str | None = None,
           *, shard_index: int = 0, shard_count: int = 1) -> dict:
    active = json.loads((ROOT / "results/active-config.json").read_text())["config"]
    revision = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT.parent, text=True).strip()
    # JSONL records are separated by LF only. Candidate stdout can contain
    # U+0085, which str.splitlines() also treats as a separator.
    rows = [json.loads(line) for line in results_file.read_text().split("\n") if line]
    if any(row.get("config") != active or row.get("revision") != revision for row in rows):
        raise ValueError("Replay input does not match the current source revision and benchmark configuration")
    run_ids = {row.get("run_id") for row in rows}
    if len(run_ids) > 1 or None in run_ids:
        raise ValueError("Replay input must contain exactly one benchmark run")
    catalog = json.loads((ROOT / "catalog.json").read_text())
    sizes = {item["script_hash"]: item["serialised_size"] for item in catalog["scripts"]}
    candidates = {row["script_hash"]: row for row in rows if row.get("status") == "candidate"
                  and HASH.fullmatch(row.get("script_hash", ""))}
    ordered = sorted(candidates, key=lambda h: (sizes.get(h, 10**12), h))
    existing = set(json.loads(OUTPUT.read_text()))
    all_pending = [h for h in ordered if h not in existing]
    pending = all_pending[shard_index::shard_count]
    shard_pending = len(pending)
    if limit:
        pending = pending[:limit]
    outcomes = {}
    for script_hash in pending:
        row = candidates[script_hash]
        metadata = json.loads((ROOT / f"S_{script_hash}/metadata.json").read_text())
        typ, binder, _ = witness_type(metadata)
        model = typed_model(row.get("stdout", ""), binder, typ)
        if model is None:
            result = "no typed model in benchmark result"
        else:
            result = save_witness(
                script_hash, model, cek_fuel, source_revision=revision,
                baseline_run_id=row["run_id"], source="native Z3 model from benchmark JSONL",
                replay_note="not requested during benchmark search",
            )
        outcomes[script_hash] = result
        print(f"{script_hash}: {result}", flush=True)
    summary = {
        "run_id": next(iter(run_ids), None), "revision": revision, "head_sha": head_sha or revision,
        "config": active,
        "candidates": len(ordered), "already_verified": len(ordered) - len([h for h in ordered if h not in existing]),
        "pending_total": len(all_pending), "shard_index": shard_index,
        "shard_count": shard_count, "shard_pending": shard_pending,
        "skipped_due_to_limit": shard_pending - len(pending),
        "attempted": len(outcomes), "newly_verified": sum(v == "verified" for v in outcomes.values()),
        "outcomes": outcomes,
    }
    (ROOT / "results/replay-summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    verified = json.loads(OUTPUT.read_text())
    evidence = {}
    for script_hash, record in verified.items():
        witness = ROOT / f"S_{script_hash}/ReplayWitness.lean"
        source = witness.read_text()
        if hashlib.sha256(source.encode()).hexdigest() != record["witness_sha256"]:
            raise ValueError(f"Witness digest mismatch for {script_hash}")
        evidence[script_hash] = source
    (ROOT / "results/replay-evidence.json").write_text(
        json.dumps(evidence, ensure_ascii=False, sort_keys=True) + "\n")
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results-file", type=Path, required=True)
    parser.add_argument("--limit", type=int, default=12,
                        help="Maximum new witnesses to check; 0 checks all")
    parser.add_argument("--cek-fuel", type=int, default=1000)
    parser.add_argument("--head-sha", help="PR head SHA; the checked-out revision may be a merge commit")
    parser.add_argument("--shard-index", type=int, default=0)
    parser.add_argument("--shard-count", type=int, default=1)
    args = parser.parse_args()
    if args.limit < 0 or not 1 <= args.cek_fuel <= 100000:
        parser.error("limit must be nonnegative and CEK fuel must be 1..100000")
    if args.head_sha and not re.fullmatch(r"[0-9a-f]{40}", args.head_sha):
        parser.error("--head-sha must be a 40-character Git SHA")
    if args.shard_count < 1 or not 0 <= args.shard_index < args.shard_count:
        parser.error("shard index must be in 0..shard-count-1")
    print(json.dumps(replay(args.results_file, args.limit, args.cek_fuel, args.head_sha,
                            shard_index=args.shard_index, shard_count=args.shard_count)))


if __name__ == "__main__":
    main()
