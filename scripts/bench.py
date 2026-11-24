#!/usr/bin/env python3
"""Run a bounded Cardano benchmark tier with editable local dependencies."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
BENCHMARK = ROOT / "benchmark"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tier", choices=("smoke", "clusters", "full"))
    parser.add_argument("--z3", type=Path, required=True)
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--limit", type=int, help="Run only the first N cases for a local pilot")
    parser.add_argument("--timeout", type=int, default=25,
                        help="Whole-process seconds per case; SMT remains fixed at 10 seconds")
    parser.add_argument("--cek-fuel", type=int, default=3000)
    parser.add_argument("--result-path-file", type=Path,
                        help="Write the JSONL path for a post-search replay step")
    args = parser.parse_args()
    if args.workers < 1 or args.timeout < 1 or not 1 <= args.cek_fuel <= 100000 or (args.limit is not None and args.limit < 1):
        parser.error("workers, timeout, CEK fuel, and limit must be positive")
    cohort = "smoke-2026-11-23" if args.tier == "smoke" else "2026-11-23"
    command = [sys.executable, "LiveScripts/benchmark.py", "--cohort", cohort,
               "--z3", str(args.z3.resolve()), "--workers", str(args.workers),
               "--timeout", str(args.timeout), "--cek-fuel", str(args.cek_fuel)]
    if args.tier == "clusters":
        command.append("--cluster-first")
    if args.tier == "clusters":
        command.append("--skip-existing")
    if args.limit:
        command.extend(("--limit", str(args.limit)))
    if args.result_path_file:
        command.extend(("--result-path-file", str(args.result_path_file.resolve())))
    subprocess.run(command, cwd=BENCHMARK, check=True)


if __name__ == "__main__":
    main()
