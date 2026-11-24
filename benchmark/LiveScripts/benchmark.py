#!/usr/bin/env python3
"""Run imported Lean properties with a wall-clock limit per script.

Results marked candidate are solver models only. They do not count as verified
ledger contexts or raise the public progress curve.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path
from tempfile import TemporaryDirectory


REPO = Path(__file__).resolve().parent.parent
HASH = re.compile(r"[0-9a-f]{56}\Z")
FUEL_CALL = re.compile(
    r"(\bcekExecuteProgram\s+script_[0-9a-f]{56}\.script\s+\([^)]+\)\s+)(\d+)(\)\])"
)


def property_at_fuel(source: str, fuel: int) -> str:
    """Change the one CEK bound in a generated property without editing the corpus."""
    source, count = FUEL_CALL.subn(lambda match: match[1] + str(fuel) + match[3], source)
    if count != 1:
        raise ValueError(f"expected one generated CEK call, found {count}")
    source, count = re.subn(r"(CEK fuel: )\d+", lambda match: match[1] + str(fuel), source)
    if count != 1:
        raise ValueError(f"expected one CEK fuel comment, found {count}")
    return source


def classify(code: int | None, output: str, timed_out: bool) -> str:
    if timed_out:
        return "timeout"
    if code == 0 and "✅ Expected Falsified" in output and "Counterexample:" in output:
        return "candidate"
    if "❌ Unexpected Valid" in output:
        return "unknown"
    if code == 0 and ("Undetermined" in output or "Valid" in output):
        return "unknown"
    return "error"


def error_report(result: dict) -> dict:
    """Keep the actual Lean/SMT error without publishing build environment logs."""
    lines = (result.get("stdout", "") + "\n" + result.get("stderr", "")).splitlines()
    first = next((i for i, line in enumerate(lines) if "error:" in line), None)
    if first is None:
        details = "\n".join(lines[-20:]).strip()
        message = lines[-1].strip() if lines else "No diagnostic output recorded"
    else:
        excerpt = []
        for line in lines[first:]:
            if line.startswith(("[Start]:", "[End]:", "Some required targets")):
                break
            excerpt.append(line)
            if len(excerpt) >= 20:
                break
        details = "\n".join(excerpt).strip()[:4000]
        message = lines[first].strip()
        message = re.sub(
            r"^(?:error: )?LiveScripts/S_[0-9a-f]{56}/[^:]+:\d+:\d+: (?:error: )?",
            "", message,
        )
        message = message.removeprefix("error: ")
    kind = ("recursion_depth" if "maximum recursion depth" in message else
            "decode" if "Decoding error" in message else
            "smt" if "smt error" in message.lower() else "other")
    return {
        "script_hash": result["script_hash"],
        "run_id": result["run_id"],
        "exit_code": result.get("exit_code"),
        "kind": kind,
        "message": message,
        "details": details,
    }


def active_stage(output: str) -> str:
    stage = "elaboration"
    for line in output.splitlines():
        if line.startswith("[Start]: "):
            stage = line.removeprefix("[Start]: ").lower().replace(" ", "_")
        elif line.startswith("[End]: "):
            stage = "between_stages"
    return stage


def run_command(command: list[str], timeout: float, env: dict[str, str]) -> tuple[int, str, str, bool]:
    process = subprocess.Popen(
        command, cwd=REPO, env=env,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True,
    )
    timed_out = False
    try:
        stdout, stderr = process.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        os.killpg(process.pid, signal.SIGKILL)
        stdout, stderr = process.communicate()
    return (process.returncode, stdout.decode("utf-8", errors="replace"),
            stderr.decode("utf-8", errors="replace"), timed_out)


def run_case(script_hash: str, timeout: int, env: dict[str, str], cek_fuel: int = 3000) -> dict:
    started = time.monotonic()
    deadline = started + timeout
    module = f"LiveScripts.S_{script_hash}.Script"
    code, build_output, build_errors, build_timeout = run_command(
        ["lake", "build", module], timeout, env)
    if build_timeout or code != 0:
        output, errors, timed_out = build_output, build_errors, build_timeout
        status = "timeout" if build_timeout else "error"
        stage = "script_build" if build_timeout else None
    else:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            code, output, errors, timed_out = None, "", "", True
            status, stage = "timeout", "script_build"
        else:
            source = (REPO / "LiveScripts" / f"S_{script_hash}" / "Properties.lean").read_text()
            with TemporaryDirectory(prefix="cardano-fuel-") as directory:
                property_path = Path(directory) / "Properties.lean"
                property_path.write_text(property_at_fuel(source, cek_fuel))
                # A temporary module ensures that every search runs Blaster anew.
                code, output, errors, timed_out = run_command(
                    ["lake", "lean", str(property_path)], remaining, env)
            status = classify(code, output + errors, timed_out)
            stage = active_stage(output) if timed_out else None
    return {
        "script_hash": script_hash, "status": status, "cek_fuel": cek_fuel,
        "timeout_stage": stage,
        "seconds": round(time.monotonic() - started, 3),
        # A replay must use the complete model from this run, including its first line.
        "exit_code": code, "stdout": output if status == "candidate" else output[-16000:],
        "stderr": errors[-4000:],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cohort", default="2026-11-23")
    parser.add_argument("--script", help="Run a single script hash from the cohort")
    parser.add_argument("--limit", type=int, help="Stop after this many cases")
    parser.add_argument("--offset", type=int, default=0)
    parser.add_argument("--timeout", type=int, default=25, help="Hard wall-clock seconds per case, including optimization")
    parser.add_argument("--cek-fuel", type=int, default=3000,
                        help="CEK step bound for each Blaster search (default: 3000)")
    parser.add_argument("--workers", type=int, default=1)
    parser.add_argument("--cluster-first", action="store_true", help="Try the smallest script in each structural family first")
    parser.add_argument("--skip-existing", action="store_true", help="Skip cases already run with this configuration")
    parser.add_argument("--z3", type=Path, help="Path to Z3 5.4 or newer")
    parser.add_argument("--result-path-file", type=Path,
                        help="Write the exact JSONL path for a post-search replay step")
    args = parser.parse_args()
    if (args.limit is not None and args.limit < 1) or args.timeout < 1 or args.offset < 0 or args.workers < 1 or not 1 <= args.cek_fuel <= 100000:
        parser.error("limit, timeout, workers and CEK fuel must be positive; offset cannot be negative")
    cohort = json.loads((REPO / "LiveScripts/cohorts" / f"{args.cohort}.json").read_text())
    hashes = cohort["script_hashes"]
    if args.cluster_first:
        catalog = json.loads((REPO / "LiveScripts/catalog.json").read_text())
        members = {item["script_hash"]: item for item in catalog["scripts"]}
        representatives: dict[str, dict] = {}
        for script_hash in hashes:
            item = members[script_hash]
            family = item.get("cluster_id") or script_hash
            old = representatives.get(family)
            if old is None or (item["serialised_size"], script_hash) < (old["serialised_size"], old["script_hash"]):
                representatives[family] = item
        hashes = [item["script_hash"] for item in sorted(
            representatives.values(), key=lambda item: (item["serialised_size"], item["script_hash"]))]
    if args.script:
        if not HASH.fullmatch(args.script) or args.script not in hashes:
            parser.error("--script must be a hash in the selected cohort")
        hashes = [args.script]
    env = os.environ.copy()
    if args.z3:
        z3 = args.z3.resolve()
        if not z3.is_file():
            parser.error(f"Z3 executable not found: {z3}")
        env["PATH"] = str(z3.parent) + os.pathsep + env["PATH"]
        z3_include = z3.parent.parent / "include"
        z3_library = next(
            (directory for directory in (z3.parent, z3.parent.parent / "lib")
             if (directory / "libz3.a").is_file() or (directory / "libz3.dylib").is_file()),
            None,
        )
        if not (z3_include / "z3.h").is_file() or z3_library is None:
            parser.error("--z3 must belong to an installation with z3.h and libz3")
        env["Z3_INC_PATH"] = str(z3_include)
        env["Z3_LIB_PATH"] = str(z3_library)
        if os.name == "posix":
            library_var = "DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
            env[library_var] = str(z3_library) + os.pathsep + env.get(library_var, "")
    else:
        z3_path = shutil.which("z3")
        if not z3_path:
            parser.error("z3 is required; pass --z3 /path/to/z3")
    version = subprocess.run(["z3", "-version"], env=env, capture_output=True, text=True, check=True).stdout
    match = re.search(r"version (\d+)\.(\d+)", version)
    if not match or tuple(map(int, match.groups())) < (5, 4):
        parser.error(f"Z3 5.4 or newer is required; found {version.strip()}")
    results_dir = REPO / "LiveScripts/results"
    results_dir.mkdir(exist_ok=True)
    latest_path = results_dir / "latest.json"
    latest = json.loads(latest_path.read_text()) if latest_path.exists() else {}
    manifest = json.loads((REPO / "lake-manifest.json").read_text())
    package_revs = {item["name"]: item.get("rev", f"path:{item.get('dir', '')}") for item in manifest["packages"]
                    if item["name"] in ("Blaster", "PlutusCore", "CardanoLedgerApi")}
    lab_root = REPO.parent if (REPO.parent / "upstreams.json").is_file() else None
    lab_fingerprint = None
    if lab_root:
        lab_revision = subprocess.run(["git", "rev-parse", "HEAD"], cwd=lab_root,
                                      capture_output=True, text=True, check=True).stdout.strip()
        lab_diff = subprocess.run(
            ["git", "diff", "--binary", "HEAD", "--", "packages", "benchmark/lakefile.lean",
             "benchmark/LiveScripts", ":(exclude)benchmark/LiveScripts/results"],
            cwd=lab_root, capture_output=True, check=True).stdout
        lab_fingerprint = {"revision": lab_revision,
                           "tracked_diff": hashlib.sha256(lab_diff).hexdigest()}
    config = hashlib.sha256(json.dumps({
        "packages": package_revs, "z3": version.strip(), "wall_timeout": args.timeout,
        "workers": args.workers,
        "cek_fuel": args.cek_fuel,
        "generator": hashlib.sha256((REPO / "LiveScripts/import_corpus.py").read_bytes()).hexdigest(),
        "runner": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "lab": lab_fingerprint,
    }, sort_keys=True).encode()).hexdigest()
    (results_dir / "active-config.json").write_text(json.dumps({
        "config": config, "packages": package_revs, "z3": version.strip(),
        "wall_timeout": args.timeout, "workers": args.workers, "cohort": args.cohort,
        "cek_fuel": args.cek_fuel,
    }, indent=2, sort_keys=True) + "\n")
    if args.skip_existing:
        hashes = [h for h in hashes if latest.get(h, {}).get("config") != config]
    if not args.script:
        hashes = hashes[args.offset:][:args.limit]
    revision = subprocess.run(["git", "rev-parse", "HEAD"], cwd=REPO,
                              capture_output=True, text=True, check=True).stdout.strip()
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ") + "-" + revision[:8]
    output_path = results_dir / f"{run_id}.jsonl"
    if args.result_path_file:
        args.result_path_file.write_text(str(output_path.resolve()) + "\n")
    with output_path.open("w") as sink:
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            pending = {pool.submit(run_case, h, args.timeout, env, args.cek_fuel): h for h in hashes}
            for index, task in enumerate(as_completed(pending), 1):
                result = task.result()
                script_hash = result["script_hash"]
                result.update({"run_id": run_id, "revision": revision, "config": config,
                               "timestamp": datetime.now(timezone.utc).isoformat()})
                # Keep each JSONL record on one physical line even if a solver
                # diagnostic contains Unicode separators such as U+0085.
                sink.write(json.dumps(result) + "\n")
                sink.flush()
                if result["status"] == "error":
                    report_path = results_dir / "errors" / f"{script_hash}.json"
                    report_path.parent.mkdir(parents=True, exist_ok=True)
                    report_path.write_text(json.dumps(error_report(result), indent=2,
                                                      ensure_ascii=False) + "\n")
                latest[script_hash] = {
                    "status": result["status"], "seconds": result["seconds"],
                    "cek_fuel": args.cek_fuel,
                    "timeout_stage": result["timeout_stage"], "config": config, "run_id": run_id,
                    "note": "Blaster returned a CardanoLedgerApi-valid context candidate; independent replay is pending."
                    if result["status"] == "candidate" else
                    f"No counterexample at CEK fuel {args.cek_fuel}; a higher fuel limit may reveal one."
                    if "❌ Unexpected Valid" in result["stdout"] + result["stderr"] else
                    f"Last run: {result['status']}"
                    + (f" during {result['timeout_stage']}" if result["timeout_stage"] else "")
                    + f" after {result['seconds']} s.",
                }
                latest_path.write_text(json.dumps(latest, indent=2, sort_keys=True) + "\n")
                print(f"{index}/{len(hashes)} {script_hash} {result['status']}"
                      f" {result['seconds']}s {result['timeout_stage'] or ''}", flush=True)
    print(f"Results: {output_path}")


if __name__ == "__main__":
    main()
