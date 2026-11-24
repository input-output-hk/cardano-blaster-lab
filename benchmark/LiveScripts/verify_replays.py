#!/usr/bin/env python3
"""Recheck concrete Blaster witnesses before publishing verified results."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BENCHMARK = ROOT.parent
OUTPUT = ROOT / "results/verified.json"
PURPOSES = {
    "spend": "spending",
    "mint": "minting",
    "reward": "rewarding",
    "cert": "certifying",
}
WITNESS_FILE = re.compile(r"benchmark/LiveScripts/S_([0-9a-f]{56})/ReplayWitness\.(?:lean|json)\Z")


def check_source(script_hash: str, version: str, purpose: str, fuel: int) -> str:
    module = f"LiveScripts.S_{script_hash}"
    term = "replayContext" if version == "plutusV3" else "replayInput"
    context = term if version == "plutusV3" else f"{term}.ctx"
    function = PURPOSES[purpose]
    return f"""import CardanoLedgerApi.V{version[-1]}
import {module}.ReplayWitness
import PlutusCore.UPLC.CekMachine

open CardanoLedgerApi.V{version[-1]}
open CardanoLedgerApi.IsData.Class
open PlutusCore.UPLC.CekMachine

-- All three checks must evaluate to true for Lake to build this module.
#guard valid{function.capitalize()}Context {term}
#guard (IsData.fromData (IsData.toData {context}) : Option ScriptContext) == some {context}
#guard match cekExecuteProgram script_{script_hash}.script ({function}Inputs {term}) {fuel} with
  | .Halt _ => true
  | _ => false
"""


def verify(path: Path, *, replay: bool = True) -> tuple[str, dict]:
    script_hash = path.parent.name.removeprefix("S_")
    if not re.fullmatch(r"[0-9a-f]{56}", script_hash):
        raise ValueError(f"Invalid script directory: {path.parent}")
    metadata = json.loads((path.parent / "metadata.json").read_text())
    if metadata["script_hash"] != script_hash:
        raise ValueError(f"Metadata hash mismatch: {path}")
    provenance_path = path.with_suffix(".json")
    provenance = json.loads(provenance_path.read_text())
    if provenance["script_hash"] != script_hash:
        raise ValueError(f"Replay provenance hash mismatch: {provenance_path}")
    fuel = provenance.get("cek_fuel", 1000)
    if type(fuel) is not int or not 1 <= fuel <= 100000:
        raise ValueError(f"Invalid CEK fuel in {provenance_path}: {fuel}")
    version, purpose = metadata["script_type"], metadata["search_purpose"]
    if version not in {"plutusV1", "plutusV2", "plutusV3"} or purpose not in PURPOSES:
        raise ValueError(f"Unsupported replay type: {version}/{purpose}")
    if replay:
        source = check_source(script_hash, version, purpose, fuel)
        check = path.with_name("ReplayCheck.lean")
        if check.exists():
            raise ValueError(f"Temporary replay module already exists: {check}")
        try:
            check.write_text(source)
            module = f"LiveScripts.S_{script_hash}.ReplayCheck"
            result = subprocess.run(
                ["lake", "build", module], cwd=BENCHMARK, env=os.environ.copy(),
                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300,
            )
            if result.returncode:
                raise RuntimeError(f"{module} failed:\n{result.stdout[-6000:]}")
        finally:
            check.unlink(missing_ok=True)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    return script_hash, {
        "status": "verified",
        "note": f"Concrete context passed ledger API validity, Plutus data round-trip, and CEK halt at fuel {fuel}.",
        "replay": f"LiveScripts/S_{script_hash}/ReplayWitness.lean",
        "provenance": f"LiveScripts/S_{script_hash}/ReplayWitness.json",
        "witness_sha256": digest,
        "checks": ["valid_context", "is_data_roundtrip", f"cek_halt_fuel_{fuel}"],
    }


def select_changed_witnesses(changed: list[str]) -> set[str] | None:
    """Use targeted replay only when the PR cannot change old witness semantics."""
    selected = set()
    for name in changed:
        match = WITNESS_FILE.fullmatch(name)
        if match:
            if not (BENCHMARK.parent / name).is_file():
                return None
            selected.add(match.group(1))
        elif (name == "benchmark/LiveScripts/README.md" or
              name.startswith("benchmark/LiveScripts/results/") or
              name.startswith("benchmark/cardano-dashboard/")):
            continue
        else:
            return None
    return selected


def changed_files(base: str) -> list[str]:
    if not re.fullmatch(r"[0-9a-f]{40}", base):
        raise ValueError("--changed-from must be a full Git commit SHA")
    result = subprocess.run(
        ["git", "diff", "--name-only", "-z", base, "HEAD"],
        cwd=BENCHMARK, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
    )
    return [path.decode("utf-8", "surrogateescape") for path in result.stdout.split(b"\0") if path]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Require the committed result to match the replay")
    parser.add_argument("--changed-from", metavar="BASE_SHA",
                        help="On a PR, replay only changed witnesses when no code affecting old witnesses changed")
    args = parser.parse_args()
    if args.changed_from and not args.check:
        parser.error("--changed-from requires --check")
    paths = sorted(ROOT.glob("S_*/ReplayWitness.lean"))
    stored = json.loads(OUTPUT.read_text()) if args.check else None
    if args.changed_from:
        selected = select_changed_witnesses(changed_files(args.changed_from))
        if selected is None:
            print("Replay scope: core files changed; checking every witness", flush=True)
        else:
            inventory = dict(verify(path, replay=False) for path in paths)
            if inventory != stored:
                raise SystemExit("Verified result inventory differs from the committed witnesses")
            paths = [path for path in paths if path.parent.name.removeprefix("S_") in selected]
            if len(paths) != len(selected):
                raise SystemExit("A changed witness is missing from the verified inventory")
            print(f"Replay scope: {len(paths)} changed of {len(inventory)} verified witnesses; inventory passed", flush=True)
    total = len(paths)
    results = {}
    for index, path in enumerate(paths, 1):
        script_hash, result = verify(path)
        if stored is not None and stored.get(script_hash) != result:
            raise SystemExit(f"Replay {index}/{total} failed: committed result differs for {script_hash}")
        results[script_hash] = result
        print(f"Replay {index}/{total} passed {script_hash}", flush=True)
    if args.check:
        if not args.changed_from and stored != results:
            raise SystemExit("Verified results differ from replayed witnesses")
    else:
        OUTPUT.write_text(json.dumps(results, indent=2, sort_keys=True) + "\n")
    print(f"Verified {len(results)} concrete replay(s)", flush=True)


if __name__ == "__main__":
    main()
