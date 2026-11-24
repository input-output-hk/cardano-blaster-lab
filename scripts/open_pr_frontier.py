#!/usr/bin/env python3
"""Read replay evidence for the current heads of open lab PRs."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import urlencode


VERIFIED_PATH = "benchmark/LiveScripts/results/verified.json"
HASH = re.compile(r"[0-9a-f]{56}\Z")
SHA = re.compile(r"[0-9a-f]{40}\Z")
REPLAY_STEP = "Verify concrete replay witnesses"
POST_SEARCH_STEP = "Replay new counterexamples"


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
        if run.get("conclusion") != "success":
            return None
        pages = api(f"repos/{repository}/actions/runs/{run['id']}/jobs", paginate=True)
        for page in pages:
            for job in page["jobs"]:
                if job["name"] != "benchmark":
                    continue
                steps = {step["name"]: step for step in job.get("steps", [])}
                precheck = steps.get(REPLAY_STEP)
                if precheck is None or precheck["conclusion"] != "success":
                    continue
                postcheck = steps.get(POST_SEARCH_STEP)
                if postcheck is not None and postcheck["conclusion"] != "success":
                    return None
                checked = postcheck or precheck
                return {"url": job["html_url"], "checked_at": checked["completed_at"],
                        "run_id": run["id"], "post_search": postcheck is not None}
        # A failed replay at this head supersedes an older attempt at it.
        return None
    return None


def artifact_verified_hashes(repository: str, run_id: int, sha: str) -> set[str]:
    """Read successful replay evidence without executing code from the PR artifact."""
    with tempfile.TemporaryDirectory() as directory:
        result = subprocess.run(
            ["gh", "run", "download", str(run_id), "-R", repository,
             "-n", f"cardano-benchmark-{run_id}", "-D", directory],
            text=True, capture_output=True,
        )
        if result.returncode:
            raise RuntimeError(f"Could not download benchmark artifact for run {run_id}: {result.stderr.strip()}")
        root = Path(directory)
        verified_files = list(root.rglob("verified.json"))
        summary_files = list(root.rglob("replay-summary.json"))
        evidence_files = list(root.rglob("replay-evidence.json"))
        if len(verified_files) != 1 or len(summary_files) != 1 or len(evidence_files) != 1:
            raise ValueError(f"Incomplete replay artifact for run {run_id}")
        summary = json.loads(summary_files[0].read_text())
        revision = summary.get("revision") if isinstance(summary, dict) else None
        if not isinstance(revision, str) or summary.get("head_sha") != sha or not SHA.fullmatch(revision):
            raise ValueError(f"Replay summary revision mismatch for run {run_id}")
        records = json.loads(verified_files[0].read_text())
        hashes = verified_hashes(records)
        witnesses = json.loads(evidence_files[0].read_text())
        if not isinstance(witnesses, dict) or set(witnesses) != hashes:
            raise ValueError(f"Incomplete replay witness evidence for run {run_id}")
        for script_hash in hashes:
            witness = witnesses.get(script_hash)
            if not isinstance(witness, str) or hashlib.sha256(witness.encode()).hexdigest() != records[script_hash].get("witness_sha256"):
                raise ValueError(f"Missing or mismatched replay witness for {script_hash} in run {run_id}")
        return hashes


def collect(repository: str, published: set[str]) -> list[dict]:
    pages = api(f"repos/{repository}/pulls?state=open&base=main", paginate=True)
    entries = []
    for page in pages:
        for pr in page:
            head = pr["head"]
            sha = head["sha"]
            if head["repo"] is None or not SHA.fullmatch(sha):
                continue
            number = pr["number"]
            replay = replay_run(repository, number, sha)
            if replay is None:
                continue
            try:
                if replay["post_search"]:
                    hashes = artifact_verified_hashes(repository, replay["run_id"], sha)
                else:
                    records = api(f"repos/{head['repo']['full_name']}/contents/{VERIFIED_PATH}?ref={sha}",
                                  raw=True, allow_missing=True)
                    hashes = verified_hashes(records)
            except (ValueError, RuntimeError, json.JSONDecodeError) as exc:
                print(f"Skipping PR #{number}: {exc}", file=sys.stderr)
                continue
            if not hashes - published:
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
