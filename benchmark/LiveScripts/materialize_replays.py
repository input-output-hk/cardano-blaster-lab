#!/usr/bin/env python3
"""Turn native Blaster candidate models into checked replay witnesses."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path

from verify_replays import BENCHMARK, OUTPUT, ROOT, verify


def typed_model(output: str, binder: str, typ: str) -> str | None:
    if "✅ Expected Falsified" not in output:
        return None
    marker = f"- {binder}: "
    lines = output.splitlines()
    for i, line in enumerate(lines):
        if marker not in line or "[raw Z3 value" in line:
            continue
        expression = [line.split(marker, 1)[1]]
        for following in lines[i + 1:]:
            if following.startswith(("info:", "error:", "warning:")):
                break
            expression.append(following)
        value = "\n".join(expression).strip()
        if value.startswith("(") and value.endswith(f" : {typ})"):
            return value
    return None


def materialize(script_hash: str, wall_timeout: int, cek_fuel: int) -> str:
    directory = ROOT / f"S_{script_hash}"
    metadata = json.loads((directory / "metadata.json").read_text())
    version = metadata["script_type"]
    typ = "ScriptContext" if version == "plutusV3" else metadata["search_purpose"].capitalize() + "ingInput"
    if metadata["search_purpose"] == "spend" and version != "plutusV3":
        typ = "SpendingInput"
    if metadata["search_purpose"] == "cert" and version != "plutusV3":
        typ = "CertifyingInput"
    binder = "ctx" if version == "plutusV3" else "input"
    name = "replayContext" if version == "plutusV3" else "replayInput"
    witness = directory / "ReplayWitness.lean"
    if witness.exists():
        return "already materialized"

    property_source = (directory / "Properties.lean").read_text()
    old = "#blaster (timeout: 10)"
    if property_source.count(old) != 1 or property_source.count(" 1000)]") != 1:
        raise ValueError(f"Unexpected property syntax for {script_hash}")
    search = directory / "ReplaySearch.lean"
    if search.exists():
        raise ValueError(f"Temporary search module already exists: {search}")
    replay_note = "not reported"
    try:
        search.write_text(property_source.replace(old, "#blaster (backend: ffi) (replay: 1) (timeout: 10)")
                          .replace(" 1000)]", f" {cek_fuel})]"))
        module = f"LiveScripts.S_{script_hash}.ReplaySearch"
        try:
            run = subprocess.run(["lake", "build", module], cwd=BENCHMARK, env=os.environ.copy(),
                                 text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 timeout=wall_timeout)
        except subprocess.TimeoutExpired:
            return "search wall timeout"
        if run.returncode:
            return f"search error: {run.stdout[-300:].strip()}"
        model = typed_model(run.stdout, binder, typ)
        if model is None:
            return "no typed native model"
        # Lean's pretty printer may put the outer `ctx` field on a new layout
        # line after a constructor application; the parser then expects `}`.
        if version != "plutusV3":
            for field in ("redeemer", "ctx"):
                model = model.replace(f",\n  {field} :=", f", {field} :=")
        replay_note = next((line.split("⚠️ Replay inconclusive:", 1)[1].strip()
                            for line in run.stdout.splitlines() if "⚠️ Replay inconclusive:" in line),
                           "not reported")
    finally:
        search.unlink(missing_ok=True)

    imports = (f"import CardanoLedgerApi.V{version[-1]}\n"
               f"import LiveScripts.S_{script_hash}.Script\n\n"
               f"open CardanoLedgerApi.V{version[-1]}\n\n")
    witness.write_text(imports +
                       "/-- Typed context reconstructed from a native Z3 model. -/\n" +
                       f"def {name} : {typ} := {model}\n")
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=BENCHMARK, text=True).strip()
    provenance = witness.with_suffix(".json")
    provenance.write_text(json.dumps({
        "script_hash": script_hash,
        "baseline_run_id": json.loads((ROOT / "results/latest.json").read_text()).get(script_hash, {}).get("run_id"),
        "witness_source": "native Z3 model of Properties.lean",
        "source_revision": revision,
        "cek_fuel": cek_fuel,
        "backend": "ffi",
        "search_options": "(backend: ffi) (replay: 1) (timeout: 10) (verbose: 1) (solve-result: 1)",
        "blaster_internal_replay": replay_note,
        "verification": "standalone concrete replay through CardanoLedgerApi and PlutusCore CEK",
    }, indent=2) + "\n")
    try:
        _, result = verify(witness)
    except Exception as exc:
        if "ReplayCheck.lean:" in str(exc):
            witness.rename(witness.with_name("CandidateWitness.lean"))
            record = json.loads(provenance.read_text())
            message = str(exc)
            record["replay_failure"] = (
                "cek_not_halt_fuel_1000" if "cekExecuteProgram" in message else
                "data_roundtrip_failed" if "IsData.fromData" in message else
                "context_validity_failed" if "valid" in message else
                "replay_guard_failed"
            )
            provenance.with_name("CandidateWitness.json").write_text(json.dumps(record, indent=2) + "\n")
            provenance.unlink()
        else:
            witness.unlink(missing_ok=True)
            provenance.unlink(missing_ok=True)
        return f"replay failed: {str(exc)[-300:]}"
    verified = json.loads(OUTPUT.read_text()) if OUTPUT.exists() else {}
    verified[script_hash] = result
    OUTPUT.write_text(json.dumps(verified, indent=2, sort_keys=True) + "\n")
    return "verified"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hash", action="append", default=[], help="One script hash; repeat to select more")
    parser.add_argument("--limit", type=int, default=1, help="Smallest unverified candidates to attempt")
    parser.add_argument("--version", choices=["plutusV1", "plutusV2", "plutusV3"])
    parser.add_argument("--wall-timeout", type=int, default=120)
    parser.add_argument("--cek-fuel", type=int, default=1000)
    args = parser.parse_args()
    catalog = json.loads((ROOT / "catalog.json").read_text())
    sizes = {item["script_hash"]: item["serialised_size"] for item in catalog["scripts"]}
    versions = {item["script_hash"]: item["script_type"] for item in catalog["scripts"]}
    latest = json.loads((ROOT / "results/latest.json").read_text())
    hashes = args.hash or [key for key, value in latest.items()
                           if value["status"] == "candidate" and
                           (not args.version or versions.get(key) == args.version) and
                           not (ROOT / f"S_{key}/ReplayWitness.lean").exists()]
    hashes = sorted(set(hashes), key=lambda key: (sizes.get(key, 10**12), key))
    if not args.hash and args.limit > 0:
        hashes = hashes[:args.limit]
    if not 1 <= args.cek_fuel <= 100000:
        parser.error("--cek-fuel must be between 1 and 100000")
    for script_hash in hashes:
        if not re.fullmatch(r"[0-9a-f]{56}", script_hash):
            raise ValueError(f"Invalid script hash: {script_hash}")
        print(f"{script_hash}: {materialize(script_hash, args.wall_timeout, args.cek_fuel)}", flush=True)


if __name__ == "__main__":
    main()
