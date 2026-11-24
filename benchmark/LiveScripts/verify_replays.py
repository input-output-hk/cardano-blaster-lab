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


def verify(path: Path) -> tuple[str, dict]:
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


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Require the committed result to match the replay")
    args = parser.parse_args()
    paths = sorted(ROOT.glob("S_*/ReplayWitness.lean"))
    results = dict(verify(path) for path in paths)
    if args.check:
        stored = json.loads(OUTPUT.read_text())
        if stored != results:
            raise SystemExit("Verified results differ from replayed witnesses")
    else:
        OUTPUT.write_text(json.dumps(results, indent=2, sort_keys=True) + "\n")
    print(f"Verified {len(results)} concrete replay(s)")


if __name__ == "__main__":
    main()
