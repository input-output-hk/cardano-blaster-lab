#!/usr/bin/env python3
"""Freeze a small, version/purpose/size-stratified script cohort."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
LIVE = ROOT / "benchmark/LiveScripts"
SOURCE = "2026-11-23"
TARGET = 48


def select() -> dict:
    catalog = json.loads((LIVE / "catalog.json").read_text())
    cohort = json.loads((LIVE / "cohorts" / f"{SOURCE}.json").read_text())
    by_hash = {item["script_hash"]: item for item in catalog["scripts"]}
    representatives: dict[str, dict] = {}
    for script_hash in cohort["script_hashes"]:
        item = by_hash[script_hash]
        family = item.get("cluster_id") or script_hash
        old = representatives.get(family)
        if old is None or (item["serialised_size"], script_hash) < (old["serialised_size"], old["script_hash"]):
            representatives[family] = item

    groups: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for item in representatives.values():
        groups[(item["script_type"], item.get("search_purpose") or "unknown")].append(item)
    for group in groups.values():
        group.sort(key=lambda item: (item["serialised_size"], item["script_hash"]))

    chosen: set[str] = set()
    for rank in range(5):
        for key in sorted(groups):
            group = groups[key]
            position = round(rank * (len(group) - 1) / 4)
            chosen.add(group[position]["script_hash"])
            if len(chosen) == TARGET:
                break
        if len(chosen) == TARGET:
            break
    if len(chosen) < TARGET:
        remaining = (item for item in representatives.values()
                     if item["script_hash"] not in chosen)
        ranked = sorted(remaining, key=lambda item:
                        hashlib.sha256(item["script_hash"].encode()).digest())
        chosen.update(item["script_hash"] for item in ranked[:TARGET - len(chosen)])

    ordered = sorted(chosen, key=lambda script_hash:
                     (by_hash[script_hash]["serialised_size"], script_hash))
    return {
        "schema_version": 1,
        "name": f"smoke-{SOURCE}",
        "source_cohort": SOURCE,
        "selection": "one smallest exact script per cluster; five size quantiles per version and observed purpose, then SHA-256 fill",
        "created_at": "2026-11-23T00:00:00Z",
        "script_hashes": ordered,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify the committed smoke cohort")
    args = parser.parse_args()
    path = LIVE / "cohorts" / f"smoke-{SOURCE}.json"
    content = json.dumps(select(), indent=2) + "\n"
    if args.check:
        if not path.exists() or path.read_text() != content:
            parser.error("smoke cohort differs from the deterministic selection")
    else:
        path.write_text(content)
    print(f"{path}: {len(select()['script_hashes'])} scripts")


if __name__ == "__main__":
    main()
