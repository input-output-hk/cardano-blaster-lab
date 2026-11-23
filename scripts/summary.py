#!/usr/bin/env python3
"""Print a compact Markdown summary for a benchmark tier."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
LIVE = ROOT / "benchmark/LiveScripts"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tier", choices=("smoke", "clusters", "full"))
    args = parser.parse_args()
    cohort_name = "smoke-2026-11-23" if args.tier == "smoke" else "2026-11-23"
    cohort = json.loads((LIVE / "cohorts" / f"{cohort_name}.json").read_text())
    latest_path = LIVE / "results/latest.json"
    active_path = LIVE / "results/active-config.json"
    if not latest_path.exists() or not active_path.exists():
        print(f"## Cardano benchmark: {args.tier}\n")
        print("The benchmark did not produce results. Check the build and run logs.")
        return
    latest = json.loads(latest_path.read_text())
    active = json.loads(active_path.read_text())["config"]
    entries = [latest[h] for h in cohort["script_hashes"]
               if h in latest and latest[h].get("config") == active]
    counts = Counter(item["status"] for item in entries)
    stages = Counter(item.get("timeout_stage") or "unclassified" for item in entries
                     if item["status"] == "timeout")
    print(f"## Cardano benchmark: {args.tier}\n")
    print(f"Cohort `{cohort_name}`: {len(entries)} attempted of {len(cohort['script_hashes'])} scripts.\n")
    print("| Result | Count |")
    print("| --- | ---: |")
    for status in ("verified", "candidate", "timeout", "unknown", "error"):
        print(f"| {status.capitalize()} | {counts[status]} |")
    print("\nCandidates require concrete model reconstruction and independent replay before verified credit.")
    if stages:
        print("\nTimeout stages: " + ", ".join(f"{name} {count}" for name, count in sorted(stages.items())))


if __name__ == "__main__":
    main()
