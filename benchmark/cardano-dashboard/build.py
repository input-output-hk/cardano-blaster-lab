#!/usr/bin/env python3
"""Build the standalone public Cardano Scripts dashboard."""

from __future__ import annotations

import argparse
import json
import shutil
from hashlib import sha256
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
DIST = ROOT / "dist"


def open_pr_events(entries: list[dict], cohort_hashes: dict[str, set[str]],
                   verified: dict, merged_events: list[dict]) -> list[dict]:
    events = []
    for cohort, members in cohort_hashes.items():
        published = members.intersection(verified)
        best = max([len(published)] + [event["solved_count"] for event in merged_events
                    if event["cohort"] == cohort and event.get("verified_run") is not False])
        for entry in entries:
            hashes = members.intersection(entry["verified_hashes"])
            if len(hashes) < best:
                continue
            events.append({
                "run_id": f"open-pr-{entry['number']}-{entry['head_sha']}",
                "cohort": cohort,
                "timestamp": entry["checked_at"],
                "title": entry["title"],
                "author": entry["author"],
                "solved_count": len(hashes),
                "gained": len(hashes - published),
                "regressed": len(published - hashes),
                "prs": [{"number": entry["number"], "url": entry["pr_url"]}],
                "replay_url": entry["replay_url"],
                "summary": ("The benchmark workflow passed concrete replay checks for this open PR head."
                            if len(hashes) > best else
                            "This PR matches the published verified count; it does not raise the frontier."),
                "open_pr": True,
            })
    return events


def build(open_pr_entries: list[dict] | None = None) -> dict:
    catalog = json.loads((REPO / "LiveScripts/catalog.json").read_text())
    cohort_files = sorted((REPO / "LiveScripts/cohorts").glob("*.json"))
    cohorts = [json.loads(path.read_text()) for path in cohort_files]
    runs_path = ROOT / "runs.json"
    runs = json.loads(runs_path.read_text()) if runs_path.exists() else {"events": [], "results": {}}
    latest_path = REPO / "LiveScripts/results/latest.json"
    latest = json.loads(latest_path.read_text()) if latest_path.exists() else {}
    budgets = json.loads((REPO / "LiveScripts/fuel-budgets.json").read_text())["scripts"]
    fuel_plan = json.loads((REPO / "LiveScripts/results/fuel-budget-plan.json").read_text())["scripts"]
    config_path = REPO / "LiveScripts/results/active-config.json"
    if config_path.exists():
        active_config = json.loads(config_path.read_text())["config"]
        latest = {
            key: {**result, "planned_cek_fuel": budgets.get(key),
                  "budget_changed": result.get("cek_fuel", 1000) != budgets.get(key),
                  "config_changed": result.get("config") != active_config}
            for key, result in latest.items()
        }
    verified_path = REPO / "LiveScripts/results/verified.json"
    verified = json.loads(verified_path.read_text()) if verified_path.exists() else {}
    scripts = catalog["scripts"]
    script_hashes = {item["script_hash"] for item in scripts}
    if set(budgets) != script_hashes or set(fuel_plan) != script_hashes or any(
            fuel_plan[script_hash]["cek_fuel"] != budgets[script_hash] for script_hash in script_hashes):
        raise ValueError("Fuel budget plan does not match the script catalog")
    statuses = {**latest, **runs.get("results", {}), **verified}
    cohort_hashes = {entry["name"]: set(entry["script_hashes"]) for entry in cohorts}
    for event in runs.get("events", []):
        hashes = event.get("verified_hashes")
        if hashes is not None and (len(hashes) != event.get("solved_count") or
                                   len(set(hashes)) != len(hashes) or
                                   any(script_hash not in verified or
                                       script_hash not in cohort_hashes.get(event.get("cohort"), set())
                                       for script_hash in hashes)):
            raise ValueError(f"Frontier event has unverified scripts: {event.get('run_id')}")
    for cohort, members in cohort_hashes.items():
        published_events = [event for event in runs.get("events", [])
                            if event.get("cohort") == cohort and event.get("verified_run") is not False]
        if published_events and len(members.intersection(verified)) > max(
                event["solved_count"] for event in published_events):
            raise ValueError(f"Published verified scripts exceed the frontier for {cohort}")
    public_scripts = []
    for record in scripts:
        item = dict(record)
        script_hash = record["script_hash"]
        item["planned_cek_fuel"] = budgets[script_hash]
        item["fuel_plan_basis"] = fuel_plan[script_hash]["basis"]
        item["last_search_fuel"] = fuel_plan[script_hash]["last_fuel"]
        result = dict(statuses.get(script_hash, {}))
        item["status"] = result.get("status", "unrun")
        if item["status"] == "error":
            report_path = REPO / f"LiveScripts/results/errors/{script_hash}.json"
            if report_path.exists():
                report = json.loads(report_path.read_text())
                if report["script_hash"] != script_hash or report["run_id"] != result.get("run_id"):
                    raise ValueError(f"Stale error report for {script_hash}")
                result["error_message"] = report["message"]
                result["error_report"] = f"LiveScripts/results/errors/{script_hash}.json"
        item["result"] = result
        public_scripts.append(item)
    payload = {
        "schema_version": 1,
        "scripts": public_scripts,
        "cohorts": cohorts,
        "events": runs.get("events", []) + open_pr_events(
            open_pr_entries or [], cohort_hashes, verified, runs.get("events", [])
        ),
        "counts": dict(Counter(item["status"] for item in public_scripts)),
    }
    (DIST / "assets").mkdir(parents=True, exist_ok=True)
    (DIST / "data").mkdir(parents=True, exist_ok=True)
    index = (ROOT / "index.html").read_text()
    for name in ("app.js", "styles.css"):
        digest = sha256((ROOT / name).read_bytes()).hexdigest()[:12]
        asset = f"assets/{name}"
        if index.count(f'"{asset}"') != 1:
            raise ValueError(f"Expected one reference to {asset}")
        index = index.replace(f'"{asset}"', f'"{asset}?v={digest}"')
    (DIST / "index.html").write_text(index)
    shutil.copy2(ROOT / "styles.css", DIST / "assets/styles.css")
    shutil.copy2(ROOT / "app.js", DIST / "assets/app.js")
    (DIST / "data/dashboard.json").write_text(json.dumps(payload, separators=(",", ":")))
    return {"scripts": len(public_scripts), "cohorts": len(cohorts),
            "events": len(payload["events"]), "dist": str(DIST)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--open-pr-frontier", type=Path)
    args = parser.parse_args()
    entries = json.loads(args.open_pr_frontier.read_text()) if args.open_pr_frontier else []
    print(json.dumps(build(entries)))
