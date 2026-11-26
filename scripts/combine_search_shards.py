#!/usr/bin/env python3
"""Validate search shards and publish one replay-compatible benchmark run."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
LIVE = ROOT / "benchmark/LiveScripts"


def read_json(path: Path) -> dict:
    return json.loads(path.read_text())


def combine(shards_dir: Path, hashes: list[str], budgets: dict[str, int],
            baseline_latest: dict, revision: str, workflow_run_id: str,
            shard_count: int, limit: int, output: Path) -> dict:
    if shard_count < 2 or limit < 0 or len(hashes) != len(set(hashes)):
        raise ValueError("Invalid shard count, limit, or cohort")
    prefix = f"cardano-benchmark-shard-{workflow_run_id}-"
    expected_dirs = {shards_dir / f"{prefix}{index}" for index in range(shard_count)}
    actual_dirs = set(shards_dir.glob(f"{prefix}*"))
    if actual_dirs != expected_dirs:
        raise ValueError(f"Expected {shard_count} search shard artifacts; found {len(actual_dirs)}")

    config = None
    active = None
    combined_rows = {}
    latest = dict(baseline_latest)
    merged_run_id = f"full-{workflow_run_id}"
    for index in range(shard_count):
        directory = shards_dir / f"{prefix}{index}"
        assignment = hashes[index::shard_count]
        if limit:
            assignment = assignment[:limit]
        shard_active = read_json(directory / "active-config.json")
        shard_latest = read_json(directory / "latest.json")
        if shard_active.get("cohort") != "2026-11-23":
            raise ValueError(f"Shard {index} used the wrong cohort")
        if config is None:
            config, active = shard_active["config"], shard_active
        elif shard_active != active:
            raise ValueError(f"Shard {index} used a different search configuration")
        run_ids = {shard_latest.get(script_hash, {}).get("run_id") for script_hash in assignment}
        if len(run_ids) != 1 or None in run_ids:
            raise ValueError(f"Shard {index} lacks one current run ID for its assignment")
        shard_run_id = next(iter(run_ids))
        result_file = directory / f"{shard_run_id}.jsonl"
        rows = [json.loads(line) for line in result_file.read_text().split("\n") if line]
        if len(rows) != len(assignment) or {row.get("script_hash") for row in rows} != set(assignment):
            raise ValueError(f"Shard {index} did not run its exact assignment")
        for row in rows:
            script_hash = row["script_hash"]
            record = shard_latest[script_hash]
            if (row.get("revision") != revision or row.get("config") != config or
                    row.get("run_id") != shard_run_id or row.get("cek_fuel") != budgets[script_hash] or
                    record.get("config") != config or record.get("run_id") != shard_run_id or
                    record.get("status") != row.get("status") or
                    record.get("cek_fuel") != row.get("cek_fuel")):
                raise ValueError(f"Inconsistent result for {script_hash} in shard {index}")
            combined_rows[script_hash] = dict(row, run_id=merged_run_id)
            latest[script_hash] = dict(record, run_id=merged_run_id)

    expected = {script_hash for index in range(shard_count)
                for script_hash in (hashes[index::shard_count][:limit] if limit else
                                    hashes[index::shard_count])}
    if set(combined_rows) != expected:
        raise ValueError("Combined search does not cover the selected cohort")
    output.mkdir(parents=True, exist_ok=True)
    (output / f"{merged_run_id}.jsonl").write_text(
        "".join(json.dumps(combined_rows[script_hash]) + "\n" for script_hash in hashes
                if script_hash in combined_rows))
    (output / "latest.json").write_text(json.dumps(latest, indent=2, sort_keys=True) + "\n")
    (output / "active-config.json").write_text(json.dumps(active, indent=2, sort_keys=True) + "\n")
    return {"scripts": len(combined_rows), "expected": len(hashes),
            "run_id": merged_run_id, "config": config}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shards-dir", type=Path, required=True)
    parser.add_argument("--workflow-run-id", required=True)
    parser.add_argument("--revision", required=True)
    parser.add_argument("--shard-count", type=int, default=16)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not args.workflow_run_id.isdigit():
        parser.error("--workflow-run-id must be numeric")
    cohort = read_json(LIVE / "cohorts/2026-11-23.json")["script_hashes"]
    budgets = read_json(LIVE / "fuel-budgets.json")["scripts"]
    baseline = read_json(LIVE / "results/latest.json")
    result = combine(args.shards_dir, cohort, budgets, baseline, args.revision,
                     args.workflow_run_id, args.shard_count, args.limit, args.output)
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
