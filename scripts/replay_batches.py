#!/usr/bin/env python3
"""Plan, stage, and combine exhaustive replay of a completed full sweep."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import shutil
from pathlib import Path


LAB = Path(__file__).resolve().parent.parent
LIVE = LAB / "benchmark/LiveScripts"
BATCH_SIZE = 16


class IncompleteCohort(ValueError):
    """The source workflow ran a smaller diagnostic tier."""


def read_json(path: Path) -> dict:
    return json.loads(path.read_text())


def search_run(directory: Path, revision: str) -> tuple[Path, dict, list[dict], list[str]]:
    active = read_json(next(directory.rglob("active-config.json")))
    latest = read_json(next(directory.rglob("latest.json")))
    cohort_name = active["cohort"]
    if cohort_name.startswith("smoke-"):
        raise IncompleteCohort("Smoke benchmark; exhaustive replay runs only for full sweeps")
    cohort = read_json(LIVE / f"cohorts/{cohort_name}.json")["script_hashes"]
    if any(latest.get(h, {}).get("config") != active["config"] for h in cohort):
        raise IncompleteCohort("Latest results do not cover the complete cohort under this configuration")
    latest_run_ids = {latest[h].get("run_id") for h in cohort}
    if len(latest_run_ids) != 1 or None in latest_run_ids:
        raise IncompleteCohort("Latest results do not all belong to one complete run")
    paths = list(directory.rglob(f"{next(iter(latest_run_ids))}.jsonl"))
    if len(paths) != 1:
        raise ValueError(f"Expected the current run JSONL in {directory}; found {len(paths)}")
    rows = [json.loads(line) for line in paths[0].read_text().split("\n") if line]
    if set(row["script_hash"] for row in rows) != set(cohort) or len(rows) != len(cohort):
        raise IncompleteCohort("Search artifact does not contain the complete seven-day cohort")
    if any(row.get("revision") != revision or row.get("config") != active["config"] for row in rows):
        raise ValueError("Search artifact has a different revision or configuration")
    run_ids = {row.get("run_id") for row in rows}
    if run_ids != latest_run_ids:
        raise ValueError("Search JSONL does not match the latest complete run")
    return paths[0], active, rows, cohort


def pending_hashes(rows: list[dict], baseline: dict) -> list[str]:
    catalog = read_json(LIVE / "catalog.json")
    sizes = {item["script_hash"]: item["serialised_size"] for item in catalog["scripts"]}
    return sorted((row["script_hash"] for row in rows
                   if row["status"] == "candidate" and row["script_hash"] not in baseline),
                  key=lambda h: (sizes.get(h, 10**12), h))


def plan(search_dir: Path, revision: str, batch_size: int, output: Path) -> dict:
    try:
        results_file, active, rows, _ = search_run(search_dir, revision)
    except IncompleteCohort as exc:
        with output.open("a") as sink:
            sink.write('matrix={"include":[]}\npending=0\neligible=0\n')
        return {"eligible": False, "reason": str(exc)}
    pending = pending_hashes(rows, read_json(LIVE / "results/verified.json"))
    count = math.ceil(len(pending) / batch_size)
    if count > 256:
        raise ValueError("Replay matrix exceeds GitHub Actions' 256-job limit")
    matrix = {"include": [{"index": i, "count": count} for i in range(count)]}
    values = {"matrix": json.dumps(matrix, separators=(",", ":")),
              "pending": str(len(pending)), "eligible": "1", "config": active["config"],
              "search_run_id": results_file.stem}
    with output.open("a") as sink:
        for key, value in values.items():
            sink.write(f"{key}={value}\n")
    return {"eligible": True, "pending": len(pending), "shards": count}


def stage(summary_path: Path, verified_path: Path, evidence_path: Path, output: Path) -> dict:
    summary = read_json(summary_path)
    verified = read_json(verified_path)
    evidence = read_json(evidence_path)
    output.mkdir(parents=True, exist_ok=True)
    new_hashes = {h for h, outcome in summary["outcomes"].items() if outcome == "verified"}
    new_verified = {h: verified[h] for h in new_hashes}
    new_evidence = {h: evidence[h] for h in new_hashes}
    (output / "replay-summary.json").write_text(json.dumps(summary, sort_keys=True) + "\n")
    (output / "verified-new.json").write_text(json.dumps(new_verified, sort_keys=True) + "\n")
    (output / "replay-evidence-new.json").write_text(json.dumps(new_evidence, sort_keys=True) + "\n")
    for h in new_hashes:
        source = LIVE / f"S_{h}"
        target = output / f"S_{h}"
        target.mkdir()
        for name in ("ReplayWitness.lean", "ReplayWitness.json"):
            shutil.copy2(source / name, target / name)
    return {"attempted": summary["attempted"], "newly_verified": len(new_hashes)}


def aggregate(search_dir: Path, shards_dir: Path, revision: str, output: Path) -> dict:
    _, active, rows, _ = search_run(search_dir, revision)
    baseline = read_json(LIVE / "results/verified.json")
    pending = set(pending_hashes(rows, baseline))
    shards = sorted(shards_dir.glob("cardano-replay-shard-*"))
    expected_count = math.ceil(len(pending) / BATCH_SIZE)
    if len(shards) != expected_count:
        raise ValueError(f"Expected {expected_count} replay shards; found {len(shards)}")
    outcomes = {}
    verified = dict(baseline)
    evidence = {h: (LIVE / f"S_{h}/ReplayWitness.lean").read_text() for h in baseline}
    output_live = output / "benchmark/LiveScripts"
    output_results = output_live / "results"
    output_results.mkdir(parents=True, exist_ok=True)
    run_ids = {row["run_id"] for row in rows}
    for shard in shards:
        summary = read_json(shard / "replay-summary.json")
        index = summary["shard_index"]
        if (summary["revision"] != revision or summary["head_sha"] != revision
                or summary["config"] != active["config"]
                or summary["run_id"] not in run_ids or summary["shard_count"] != expected_count
                or summary["skipped_due_to_limit"] != 0 or summary["attempted"] != summary["shard_pending"]):
            raise ValueError(f"Invalid or incomplete replay summary in {shard}")
        if set(summary["outcomes"]) != set(pending_hashes(rows, baseline)[index::expected_count]):
            raise ValueError(f"Replay shard {index} did not attempt its full assignment")
        if outcomes.keys() & summary["outcomes"].keys():
            raise ValueError("Duplicate replay outcomes")
        outcomes.update(summary["outcomes"])
        records = read_json(shard / "verified-new.json")
        witnesses = read_json(shard / "replay-evidence-new.json")
        expected_new = {h for h, status in summary["outcomes"].items() if status == "verified"}
        if set(records) != expected_new or set(witnesses) != expected_new:
            raise ValueError(f"Incomplete verified evidence in {shard}")
        for h in expected_new:
            if (records[h].get("status") != "verified"
                    or not {"valid_context", "is_data_roundtrip"}.issubset(records[h].get("checks", []))
                    or not any(str(check).startswith("cek_halt_fuel_") for check in records[h].get("checks", []))):
                raise ValueError(f"Invalid replay checks for {h}")
            if hashlib.sha256(witnesses[h].encode()).hexdigest() != records[h]["witness_sha256"]:
                raise ValueError(f"Witness digest mismatch for {h}")
            source = shard / f"S_{h}"
            if (source / "ReplayWitness.lean").read_text() != witnesses[h]:
                raise ValueError(f"Witness file mismatch for {h}")
            if read_json(source / "ReplayWitness.json")["script_hash"] != h:
                raise ValueError(f"Witness provenance mismatch for {h}")
            target = output_live / f"S_{h}"
            shutil.copytree(source, target)
        verified.update(records)
        evidence.update(witnesses)
    if set(outcomes) != pending:
        raise ValueError(f"Replay coverage incomplete: {len(pending - outcomes.keys())} candidates missing")
    summary = {"run_id": next(iter(run_ids)), "revision": revision, "config": active["config"],
               "candidates": sum(row["status"] == "candidate" for row in rows),
               "pending_total": len(pending), "attempted": len(outcomes),
               "newly_verified": len(verified) - len(baseline), "skipped_due_to_limit": 0,
               "outcomes": outcomes}
    for name, value in (("verified.json", verified), ("replay-evidence.json", evidence),
                        ("replay-summary.json", summary)):
        (output_results / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
    for name in ("latest.json", "active-config.json"):
        shutil.copy2(next(search_dir.rglob(name)), output_results / name)
    return {"attempted": len(outcomes), "newly_verified": summary["newly_verified"]}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("plan")
    p.add_argument("--search-dir", type=Path, required=True)
    p.add_argument("--revision", required=True)
    p.add_argument("--output", type=Path, required=True)
    p = sub.add_parser("stage")
    p.add_argument("--summary", type=Path, required=True)
    p.add_argument("--verified", type=Path, required=True)
    p.add_argument("--evidence", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    p = sub.add_parser("aggregate")
    p.add_argument("--search-dir", type=Path, required=True)
    p.add_argument("--shards-dir", type=Path, required=True)
    p.add_argument("--revision", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.command == "plan":
        result = plan(args.search_dir, args.revision, BATCH_SIZE, args.output)
    elif args.command == "stage":
        result = stage(args.summary, args.verified, args.evidence, args.output)
    else:
        result = aggregate(args.search_dir, args.shards_dir, args.revision, args.output)
    print(json.dumps(result))


if __name__ == "__main__":
    main()
