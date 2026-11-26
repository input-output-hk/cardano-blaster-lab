#!/usr/bin/env python3
"""Probe unresolved script budgets and preserve the exact solver result."""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path
from tempfile import TemporaryDirectory

from benchmark import classify
from fuel_budgets import ROOT, property_at_fuel, property_at_smt_timeout
from plan_fuel_budgets import NO_COUNTEREXAMPLE


BENCHMARK = ROOT.parent
RAW = ROOT / "results/fuel-budget-probes.jsonl"
OBSERVATIONS = ROOT / "results/fuel-budget-observations.json"
MAX_WALL_SECONDS = 60


def matching_sources(lake_root: Path, hashes: list[str]) -> None:
    """Ensure probes in a cached checkout use the same code and properties."""
    if lake_root == BENCHMARK:
        return
    lab = BENCHMARK.parent
    other_lab = lake_root.parent
    paths = subprocess.check_output(["git", "ls-files", "-z", "packages"], cwd=lab)
    for name in paths.split(b"\0"):
        if name:
            relative = Path(name.decode())
            if (lab / relative).read_bytes() != (other_lab / relative).read_bytes():
                raise ValueError(f"Cached checkout has different package code: {relative}")
    for relative in (Path("benchmark/lakefile.lean"), Path("benchmark/lake-manifest.json"),
                     Path("benchmark/lean-toolchain")):
        if (lab / relative).read_bytes() != (other_lab / relative).read_bytes():
            raise ValueError(f"Cached checkout has different benchmark dependencies: {relative}")
    for script_hash in hashes:
        relative = Path(f"LiveScripts/S_{script_hash}/Properties.lean")
        if (BENCHMARK / relative).read_bytes() != (lake_root / relative).read_bytes():
            raise ValueError(f"Cached checkout has a different property: {script_hash}")


def run_probe(script_hash: str, fuel: int, lake_root: Path, timeout: int,
              smt_timeout: int,
              env: dict[str, str], revision: str, z3_version: str) -> dict:
    source = (lake_root / f"LiveScripts/S_{script_hash}/Properties.lean").read_text()
    started = time.monotonic()
    with TemporaryDirectory(prefix="cardano-fuel-probe-") as directory:
        property_path = Path(directory) / "Properties.lean"
        property_path.write_text(property_at_smt_timeout(property_at_fuel(source, fuel), smt_timeout))
        process = subprocess.Popen(
            ["lake", "lean", str(property_path)], cwd=lake_root, env=env,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True,
        )
        timed_out = False
        try:
            # Leave a second for process-group cleanup inside the wall cap.
            remaining = max(0, timeout - 1 - (time.monotonic() - started))
            stdout, stderr = process.communicate(timeout=remaining)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(process.pid, signal.SIGKILL)
            stdout, stderr = process.communicate()
        except BaseException:
            os.killpg(process.pid, signal.SIGKILL)
            process.communicate()
            raise
    output = stdout.decode("utf-8", errors="replace")
    errors = stderr.decode("utf-8", errors="replace")
    status = classify(process.returncode, output + errors, timed_out)
    outcome = ("no_counterexample" if "❌ Unexpected Valid" in output + errors else
               "solver_unknown") if status == "unknown" else None
    return {
        "script_hash": script_hash, "cek_fuel": fuel, "status": status,
        "outcome": outcome, "source_revision": revision, "z3": z3_version,
        "seconds": round(time.monotonic() - started, 3),
        "wall_timeout_seconds": timeout, "smt_timeout_seconds": smt_timeout,
        "exit_code": process.returncode, "stdout": output, "stderr": errors,
    }


def selected_cases(limit: int, timeout: int, smt_timeout: int = 20) -> list[tuple[str, int]]:
    catalog = json.loads((ROOT / "catalog.json").read_text())["scripts"]
    latest = json.loads((ROOT / "results/latest.json").read_text())
    plan = json.loads((ROOT / "results/fuel-budget-plan.json").read_text())["scripts"]
    completed = set()
    attempts: dict[str, int] = {}
    for line in RAW.read_text().split("\n"):
        if not line:
            continue
        row = json.loads(line)
        attempts[row["script_hash"]] = attempts.get(row["script_hash"], 0) + 1
        if (row["status"] == "timeout" and row.get("wall_timeout_seconds", 40) >= timeout or
                row.get("outcome") == "solver_unknown" and
                row.get("smt_timeout_seconds", 10) >= smt_timeout or
                row["status"] != "timeout" and row.get("outcome") != "solver_unknown"):
            completed.add((row["script_hash"], row["cek_fuel"]))
    cases = [item for item in catalog if
             NO_COUNTEREXAMPLE.match(latest.get(item["script_hash"], {}).get("note", ""))
             and plan[item["script_hash"]]["basis"] != "observed_candidate"
             and (item["script_hash"], plan[item["script_hash"]]["cek_fuel"]) not in completed]
    cases.sort(key=lambda item: (attempts.get(item["script_hash"], 0),
                                 plan[item["script_hash"]]["script_bytes"],
                                 item["script_hash"]))
    return [(item["script_hash"], plan[item["script_hash"]]["cek_fuel"]) for item in cases[:limit]]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--script", action="append", default=[],
                        help="Probe one specific Unexpected Valid hash; repeat for more")
    parser.add_argument("--fuel", type=int,
                        help="Probe this intermediate CEK fuel for the selected --script hashes")
    parser.add_argument("--limit", type=int, default=10)
    parser.add_argument("--timeout", type=int, default=40)
    parser.add_argument("--smt-timeout", type=int, default=20,
                        help="Z3 solve limit in seconds, capped by --timeout")
    parser.add_argument("--max-probes-per-script", type=int, default=1,
                        help="Keep doubling after Unexpected Valid, up to this many probes")
    parser.add_argument("--max-fuel", type=int, default=16000)
    parser.add_argument("--lake-root", type=Path, default=BENCHMARK,
                        help="Cached benchmark checkout; package code and selected properties must match")
    parser.add_argument("--z3", type=Path, required=True)
    args = parser.parse_args()
    if (args.limit < 1 or not 2 <= args.timeout <= MAX_WALL_SECONDS or
            not 1 <= args.smt_timeout <= args.timeout or
            args.max_probes_per_script < 1 or
            not 1 <= args.max_fuel <= 100000 or
            args.fuel is not None and not 1 <= args.fuel <= args.max_fuel):
        parser.error("--limit and --max-probes-per-script must be positive; "
                     "--timeout must be 2..60 seconds; --smt-timeout must be 1..timeout; "
                     "--max-fuel must be 1..100000; --fuel must be 1..max-fuel")
    if args.fuel is not None and not args.script:
        parser.error("--fuel requires at least one --script")
    lake_root, z3 = args.lake_root.resolve(), args.z3.resolve()
    if not (lake_root / "lakefile.lean").is_file():
        parser.error(f"Benchmark checkout not found: {lake_root}")
    if not z3.is_file() or not (z3.parent.parent / "include/z3.h").is_file():
        parser.error("--z3 must point into a Z3 installation with headers")
    env = os.environ.copy()
    env["PATH"] = str(z3.parent) + os.pathsep + env["PATH"]
    env["Z3_INC_PATH"] = str(z3.parent.parent / "include")
    env["Z3_LIB_PATH"] = str(z3.parent)
    if sys.platform == "darwin":
        env["DYLD_LIBRARY_PATH"] = str(z3.parent) + os.pathsep + env.get("DYLD_LIBRARY_PATH", "")
    version = subprocess.check_output([str(z3), "-version"], text=True).strip()
    match = re.search(r"version (\d+)\.(\d+)", version)
    if not match or tuple(map(int, match.groups())) < (5, 4):
        parser.error(f"Z3 5.4 or newer is required: {version}")
    if args.script:
        latest = json.loads((ROOT / "results/latest.json").read_text())
        plan = json.loads((ROOT / "results/fuel-budget-plan.json").read_text())["scripts"]
        for script_hash in args.script:
            if (not re.fullmatch(r"[0-9a-f]{56}", script_hash) or
                    not NO_COUNTEREXAMPLE.match(latest.get(script_hash, {}).get("note", ""))):
                parser.error(f"--script is not an Unexpected Valid script hash: {script_hash}")
        cases = [(script_hash, args.fuel or plan[script_hash]["cek_fuel"])
                 for script_hash in dict.fromkeys(args.script)]
    else:
        cases = selected_cases(args.limit, args.timeout, args.smt_timeout)
    matching_sources(lake_root, [script_hash for script_hash, _ in cases])
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=lake_root, text=True).strip()
    observations = json.loads(OBSERVATIONS.read_text())
    with RAW.open("a") as sink:
        for index, (script_hash, fuel) in enumerate(cases, 1):
            for attempt in range(args.max_probes_per_script):
                if fuel > args.max_fuel:
                    break
                row = run_probe(script_hash, fuel, lake_root, args.timeout,
                                args.smt_timeout, env, revision, version)
                sink.write(json.dumps(row) + "\n")
                sink.flush()
                observation = {key: row[key] for key in
                               ("script_hash", "cek_fuel", "status", "outcome", "source_revision", "seconds")}
                observation["source"] = "Raw local Z3 probe in results/fuel-budget-probes.jsonl"
                observations["observations"].append(observation)
                OBSERVATIONS.write_text(json.dumps(observations, indent=2, sort_keys=True) + "\n")
                subprocess.run([sys.executable, str(ROOT / "plan_fuel_budgets.py"), "--write"],
                               stdout=subprocess.DEVNULL, check=True)
                print(f"{index}/{len(cases)} {script_hash} fuel={fuel} {row['status']}"
                      f" {row['outcome'] or ''}"
                      f" {row['seconds']}s", flush=True)
                if row["outcome"] != "no_counterexample":
                    break
                next_plan = json.loads((ROOT / "results/fuel-budget-plan.json").read_text())["scripts"]
                next_fuel = next_plan[script_hash]["cek_fuel"]
                if next_fuel <= fuel or next_fuel > args.max_fuel:
                    break
                fuel = next_fuel


if __name__ == "__main__":
    main()
