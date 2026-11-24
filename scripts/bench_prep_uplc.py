#!/usr/bin/env python3
"""Measure the lab's Cardano #prep_uplc case with a hard process limit."""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BENCH = ROOT / "benchmark"
CASE = BENCH / "BlasterBenchmarks/PrepUplc/SellNFT.lean"
WORKSPACE = ROOT / "packages/CardanoLedgerApiBlaster"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--z3", type=Path, required=True, help="Z3 5.4+ executable")
    parser.add_argument("--timeout", type=int, default=180, help="Whole Lean process limit in seconds")
    parser.add_argument("--output", type=Path, help="Harness JSONL output; defaults to .tools/prep-uplc/")
    args = parser.parse_args()
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    z3 = args.z3.resolve()
    include = z3.parent.parent / "include"
    library = next((directory for directory in (z3.parent, z3.parent.parent / "lib")
                    if (directory / "libz3.dylib").is_file() or (directory / "libz3.so").is_file()
                    or (directory / "libz3.a").is_file()), None)
    if not z3.is_file() or not (include / "z3.h").is_file() or library is None:
        parser.error("--z3 must belong to an installation with z3.h and libz3")
    version = subprocess.run([str(z3), "-version"], capture_output=True, text=True, check=True).stdout.strip()
    match = re.search(r"version (\d+)\.(\d+)", version)
    if not match or tuple(map(int, match.groups())) < (5, 4):
        parser.error(f"Z3 5.4 or newer is required; found {version}")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    output = args.output.resolve() if args.output else ROOT / ".tools/prep-uplc" / f"sellnft-{stamp}.jsonl"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.unlink(missing_ok=True)
    log = output.with_suffix(".log")
    env = os.environ.copy()
    env["PATH"] = str(z3.parent) + os.pathsep + env.get("PATH", "")
    env["Z3_INC_PATH"] = str(include)
    env["Z3_LIB_PATH"] = str(library)
    env["PREP_UPLC_BENCH_OUT"] = str(output)
    library_var = "DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
    env[library_var] = str(library) + os.pathsep + env.get(library_var, "")
    # A clean clone does not have the dependency .olean files yet. Build them
    # before the timed command, then measure a fresh elaboration of the case.
    build_started = time.monotonic()
    build = subprocess.Popen(
        ["lake", "build", "Benchmark.PrepUplc.Harness", "CardanoLedgerApi.V2"],
        cwd=WORKSPACE, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        start_new_session=True,
    )
    try:
        build_stdout, _ = build.communicate(timeout=900)
    except subprocess.TimeoutExpired:
        os.killpg(build.pid, signal.SIGKILL)
        build_stdout, _ = build.communicate()
        raise SystemExit("Prerequisite build exceeded 900 seconds")
    output.with_suffix(".build.log").write_bytes(build_stdout)
    if build.returncode:
        raise SystemExit(f"Prerequisite build failed; see {output.with_suffix('.build.log')}")
    build_s = round(time.monotonic() - build_started, 3)
    started = time.monotonic()
    process = subprocess.Popen(["lake", "lean", str(CASE)], cwd=WORKSPACE, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               start_new_session=True)
    timed_out = False
    try:
        stdout, _ = process.communicate(timeout=args.timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        os.killpg(process.pid, signal.SIGKILL)
        stdout, _ = process.communicate()
    log.write_bytes(stdout)
    records = [json.loads(line) for line in output.read_text().split("\n") if line] if output.exists() else []
    record = records[-1] if records else {}
    summary = {
        "case": "sellNFT@1800", "status": "timeout" if timed_out else record.get("status", "error"),
        "prep_ms": record.get("wall_ms"), "process_s": round(time.monotonic() - started, 3),
        "build_s": build_s,
        "exit_code": process.returncode, "z3": version, "output": str(output), "log": str(log),
    }
    print(json.dumps(summary, indent=2), flush=True)
    if timed_out or process.returncode or record.get("status") != "ok":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
