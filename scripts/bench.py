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
    parser.add_argument("--shard-index", type=int, default=0)
    parser.add_argument("--shard-count", type=int, default=1)
    parser.add_argument("--timeout", type=int, default=60,
                        help="Whole-process seconds per case, maximum 60")
    parser.add_argument("--smt-timeout", type=int, default=20,
                        help="Z3 solve limit in seconds")
    parser.add_argument("--result-path-file", type=Path,
                        help="Write the JSONL path for a post-search replay step")
    args = parser.parse_args()
    if (args.workers < 1 or not 2 <= args.timeout <= 60 or
            not 1 <= args.smt_timeout <= args.timeout or
            args.shard_count < 1 or not 0 <= args.shard_index < args.shard_count or
            (args.limit is not None and args.limit < 1)):
        parser.error("workers and limit must be positive; timeout must be 2..60; "
                     "smt-timeout must be 1..timeout; shard index must be in 0..shard-count-1")
    cohort = "smoke-2026-11-23" if args.tier == "smoke" else "2026-11-23"
    command = [sys.executable, "LiveScripts/benchmark.py", "--cohort", cohort,
               "--z3", str(args.z3.resolve()), "--workers", str(args.workers),
               "--timeout", str(args.timeout), "--smt-timeout", str(args.smt_timeout),
               "--shard-index", str(args.shard_index), "--shard-count", str(args.shard_count)]
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
