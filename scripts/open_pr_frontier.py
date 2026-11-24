#!/usr/bin/env python3
"""Read replay evidence for the current heads of open lab PRs."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path
from urllib.parse import urlencode


VERIFIED_PATH = "benchmark/LiveScripts/results/verified.json"
HASH = re.compile(r"[0-9a-f]{56}\Z")
SHA = re.compile(r"[0-9a-f]{40}\Z")
REPLAY_STEP = "Verify concrete replay witnesses"


def api(endpoint: str, *, raw: bool = False, paginate: bool = False,
        allow_missing: bool = False) -> dict | list | None:
    args = ["gh", "api", endpoint]
    if raw:
        args += ["-H", "Accept: application/vnd.github.raw+json"]
    if paginate:
        args += ["--paginate", "--slurp"]
    result = subprocess.run(args, text=True, capture_output=True)
    if result.returncode:
        if allow_missing and "HTTP 404" in result.stderr:
            return None
        raise RuntimeError(f"GitHub request failed for {endpoint}: {result.stderr.strip()}")
    return json.loads(result.stdout)


def verified_hashes(records: object) -> set[str]:
    """Recognize the evidence format written by the concrete replay verifier."""
    hashes = set()
    if not isinstance(records, dict):
        return hashes
    for script_hash, row in records.items():
        if not HASH.fullmatch(script_hash) or not isinstance(row, dict) or row.get("status") != "verified":
            continue
        checks = row.get("checks")
        if not isinstance(checks, list):
            continue
        checks = {check for check in checks if isinstance(check, str)}
        if not {"valid_context", "is_data_roundtrip"}.issubset(checks):
            continue
        if any(re.fullmatch(r"cek_halt_fuel_[1-9]\d*", check) for check in checks):
            hashes.add(script_hash)
    return hashes


def replay_run(repository: str, number: int, sha: str) -> dict | None:
    params = urlencode({"event": "pull_request", "head_sha": sha, "status": "completed"})
    data = api(f"repos/{repository}/actions/workflows/benchmark.yml/runs?{params}")
    for run in data["workflow_runs"]:
        if run["head_sha"] != sha or not any(pr["number"] == number for pr in run["pull_requests"]):
            continue
        pages = api(f"repos/{repository}/actions/runs/{run['id']}/jobs", paginate=True)
        for page in pages:
            for job in page["jobs"]:
                if job["name"] != "benchmark":
                    continue
                for step in job.get("steps", []):
                    if step["name"] == REPLAY_STEP and step["conclusion"] == "success":
                        return {"url": job["html_url"], "checked_at": step["completed_at"]}
        # A failed replay at this head supersedes an older attempt at it.
        return None
    return None


def collect(repository: str, published: set[str]) -> list[dict]:
    pages = api(f"repos/{repository}/pulls?state=open&base=main", paginate=True)
    entries = []
    for page in pages:
        for pr in page:
            head = pr["head"]
            sha = head["sha"]
            if head["repo"] is None or not SHA.fullmatch(sha):
                continue
            try:
                records = api(f"repos/{head['repo']['full_name']}/contents/{VERIFIED_PATH}?ref={sha}",
                              raw=True, allow_missing=True)
            except json.JSONDecodeError:
                continue
            if records is None:
                continue
            hashes = verified_hashes(records)
            if not hashes - published:
                continue
            number = pr["number"]
            replay = replay_run(repository, number, sha)
            if replay is None:
                continue
            entries.append({
                "number": number,
                "title": pr["title"],
                "author": pr["user"]["login"],
                "head_sha": sha,
                "verified_hashes": sorted(hashes),
                "checked_at": replay["checked_at"],
                "replay_url": replay["url"],
                "pr_url": pr["html_url"],
            })
    return entries


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    published = verified_hashes(json.loads((root / VERIFIED_PATH).read_text()))
    args.output.write_text(json.dumps(collect(args.repository, published), indent=2) + "\n")


if __name__ == "__main__":
    main()
