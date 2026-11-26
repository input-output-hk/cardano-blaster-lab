#!/usr/bin/env python3
"""Choose per-script fuel from observed candidates and cautious next probes.

An unknown, timeout, or error does not establish a required CEK bound. Only a
candidate result establishes that its fuel is sufficient for search.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

from fuel_budgets import DEFAULT_FUEL, ROOT, valid_fuel


MAX_FUEL = 100000
NO_COUNTEREXAMPLE = re.compile(r"No counterexample at CEK fuel (\d+);")


def plan(catalog: list[dict], latest: dict, observations: list[dict],
         witness_fuels: dict[str, int]) -> tuple[dict[str, int], dict]:
    members = {item["script_hash"]: item for item in catalog}
    if set(latest) - set(members):
        raise ValueError("Latest results contain a hash missing from the catalog")
    candidates: dict[str, list[tuple[int, str]]] = defaultdict(list)
    probes: dict[str, list[dict]] = defaultdict(list)
    for script_hash, row in latest.items():
        fuel = row.get("cek_fuel", DEFAULT_FUEL)
        if not valid_fuel(fuel):
            raise ValueError(f"Invalid result fuel for {script_hash}: {fuel}")
        if row["status"] == "candidate":
            candidates[script_hash].append((fuel, f"search run {row['run_id']}"))
    for observation in observations:
        script_hash, fuel = observation["script_hash"], observation["cek_fuel"]
        if (script_hash not in members or not valid_fuel(fuel) or
                observation.get("status") not in {"candidate", "unknown", "timeout", "error"} or
                observation.get("outcome") not in {None, "no_counterexample", "solver_unknown"} or
                not isinstance(observation.get("source"), str)):
            raise ValueError(f"Invalid fuel observation: {observation}")
        probes[script_hash].append({
            "cek_fuel": fuel, "status": observation["status"],
            "outcome": observation.get("outcome"), "source": observation["source"],
        })
        if observation["status"] == "candidate":
            candidates[script_hash].append((fuel, observation["source"]))
    for script_hash, fuel in witness_fuels.items():
        if script_hash not in members or not valid_fuel(fuel):
            raise ValueError(f"Invalid witness fuel for {script_hash}: {fuel}")
        candidates[script_hash].append((fuel, "committed ReplayWitness.json"))

    family_candidates: dict[str, list[tuple[int, str]]] = defaultdict(list)
    for script_hash, observed in candidates.items():
        family = members[script_hash].get("cluster_id")
        if family:
            family_candidates[family].append((min(fuel for fuel, _ in observed), script_hash))

    budgets = {}
    evidence = {}
    for script_hash, item in sorted(members.items()):
        row = latest.get(script_hash)
        current = row.get("cek_fuel", DEFAULT_FUEL) if row else DEFAULT_FUEL
        match = NO_COUNTEREXAMPLE.match(row.get("note", "")) if row and row["status"] == "unknown" else None
        if match and int(match[1]) != current:
            raise ValueError(f"Result note and CEK fuel disagree for {script_hash}")
        no_counterexample = ([current] if match else []) + [
            probe["cek_fuel"] for probe in probes[script_hash]
            if probe["outcome"] == "no_counterexample"
        ]
        if candidates[script_hash]:
            fuel = min(value for value, _ in candidates[script_hash])
            basis = "observed_candidate"
            support = [source for value, source in candidates[script_hash] if value == fuel]
        elif row is None:
            fuel, basis, support = DEFAULT_FUEL, "unrun", []
        elif no_counterexample:
            fuel = min(MAX_FUEL, max(no_counterexample) * 2)
            fuel = max([fuel] + [probe["cek_fuel"] for probe in probes[script_hash]])
            at_fuel = [probe for probe in probes[script_hash] if probe["cek_fuel"] == fuel]
            if any(probe["status"] == "timeout" for probe in at_fuel):
                basis = "higher_fuel_timeout"
            elif any(probe["status"] == "error" for probe in at_fuel):
                basis = "higher_fuel_error"
            elif any(probe["status"] == "unknown" and probe["outcome"] != "no_counterexample"
                     for probe in at_fuel):
                basis = "unknown_at_probe"
            else:
                basis = "next_probe"
            support = [probe["source"] for probe in at_fuel]
            family = item.get("cluster_id")
            peers = [(value, peer) for value, peer in family_candidates.get(family, [])
                     if peer != script_hash and value > fuel]
            if peers:
                value, peer = min(peers)
                fuel = max(fuel, value)
                basis, support = "structural_peer_probe", [peer]
        elif row["status"] == "unknown":
            fuel, basis, support = current, "unknown_result", []
        elif row["status"] == "timeout":
            fuel, basis, support = current, "wall_timeout", []
        elif row["status"] == "error":
            fuel, basis, support = current, "lean_or_smt_error", []
        else:
            raise ValueError(f"Unknown benchmark status for {script_hash}: {row['status']}")
        budgets[script_hash] = fuel
        evidence[script_hash] = {
            "cek_fuel": fuel, "basis": basis, "support": support,
            "last_status": row["status"] if row else "unrun",
            "last_fuel": current, "script_bytes": item["serialised_size"],
        }
        if probes[script_hash]:
            evidence[script_hash]["additional_probes"] = probes[script_hash]
    report = {
        "schema_version": 1,
        "interpretation": "A candidate proves sufficiency for search, not minimality or successful replay. Other values are next probes or retained bounds, not proven sufficient.",
        "counts_by_basis": dict(sorted(Counter(row["basis"] for row in evidence.values()).items())),
        "counts_by_fuel": {str(fuel): count for fuel, count in sorted(Counter(budgets.values()).items())},
        "scripts": evidence,
    }
    return budgets, report


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Write budgets and their evidence report")
    parser.add_argument("--check", action="store_true", help="Check that committed files match this plan")
    args = parser.parse_args()
    if args.write and args.check:
        parser.error("Choose either --write or --check")
    catalog = json.loads((ROOT / "catalog.json").read_text())["scripts"]
    latest = json.loads((ROOT / "results/latest.json").read_text())
    observation_document = json.loads((ROOT / "results/fuel-budget-observations.json").read_text())
    if observation_document.get("schema_version") != 1 or not isinstance(observation_document.get("observations"), list):
        raise ValueError("Invalid fuel-budget-observations.json schema")
    observations = observation_document["observations"]
    raw_probes = [json.loads(line) for line in
                  (ROOT / "results/fuel-budget-probes.jsonl").read_text().split("\n") if line]
    captured_candidates = {
        (row["script_hash"], row["cek_fuel"], row["source_revision"])
        for row in raw_probes
        if row["status"] == "candidate" and row["exit_code"] == 0
        and "✅ Expected Falsified" in row["stdout"] and "Counterexample:" in row["stdout"]
    }
    for observation in observations:
        if (observation["status"] == "candidate" and
                (observation["script_hash"], observation["cek_fuel"],
                 observation["source_revision"]) not in captured_candidates):
            raise ValueError(f"Candidate observation lacks raw solver evidence: {observation}")
    witness_fuels = {}
    for path in ROOT.glob("S_*/ReplayWitness.json"):
        fuel = json.loads(path.read_text()).get("cek_fuel", DEFAULT_FUEL)
        if fuel > DEFAULT_FUEL:
            witness_fuels[path.parent.name.removeprefix("S_")] = fuel
    budgets, report = plan(catalog, latest, observations, witness_fuels)
    files = {
        ROOT / "fuel-budgets.json": {"schema_version": 1, "scripts": budgets},
        ROOT / "results/fuel-budget-plan.json": report,
    }
    for path, document in files.items():
        content = json.dumps(document, indent=2, sort_keys=True) + "\n"
        if args.write:
            path.write_text(content)
        elif args.check and path.read_text() != content:
            raise SystemExit(f"Outdated fuel plan: {path}")
    print(json.dumps({"scripts": len(budgets), "basis": report["counts_by_basis"],
                      "fuels": report["counts_by_fuel"]}, sort_keys=True))


if __name__ == "__main__":
    main()
