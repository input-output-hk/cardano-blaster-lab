"""Per-script CEK search bounds for the live Cardano corpus."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DEFAULT_FUEL = 1000
FUEL_CALL = re.compile(
    r"(\bcekExecuteProgram\s+script_[0-9a-f]{56}\.script\s+\([^)]+\)\s+)(\d+)(\)\])"
)


def valid_fuel(value: object) -> bool:
    return type(value) is int and 1 <= value <= 100000


def load_budgets(root: Path = ROOT) -> dict[str, int]:
    """Require one explicit budget for every catalogued script."""
    catalog = json.loads((root / "catalog.json").read_text())
    expected = {item["script_hash"] for item in catalog["scripts"]}
    document = json.loads((root / "fuel-budgets.json").read_text())
    if document.get("schema_version") != 1 or not isinstance(document.get("scripts"), dict):
        raise ValueError("Invalid fuel-budgets.json schema")
    budgets = document["scripts"]
    if budgets.keys() != expected:
        missing, extra = expected - budgets.keys(), budgets.keys() - expected
        raise ValueError(f"Fuel budgets do not match catalog: {len(missing)} missing, {len(extra)} extra")
    for script_hash, fuel in budgets.items():
        if not valid_fuel(fuel):
            raise ValueError(f"Invalid CEK fuel for {script_hash}: {fuel}")
    return budgets


def property_at_fuel(source: str, fuel: int) -> str:
    """Set the generated property's CEK bound without changing the corpus file."""
    if not valid_fuel(fuel):
        raise ValueError(f"Invalid CEK fuel: {fuel}")
    source, count = FUEL_CALL.subn(lambda match: match[1] + str(fuel) + match[3], source)
    if count != 1:
        raise ValueError(f"Expected one generated CEK call, found {count}")
    source, count = re.subn(r"(CEK fuel: )\d+", lambda match: match[1] + str(fuel), source)
    if count != 1:
        raise ValueError(f"Expected one CEK fuel comment, found {count}")
    return source


def property_at_smt_timeout(source: str, seconds: int) -> str:
    """Set the temporary search property's Z3 solve limit."""
    if type(seconds) is not int or not 1 <= seconds <= 60:
        raise ValueError(f"Invalid SMT timeout: {seconds}")
    source, count = re.subn(r"(#blaster\s+\(timeout:\s*)\d+(\))",
                            lambda match: match[1] + str(seconds) + match[2], source)
    if count != 1:
        raise ValueError(f"Expected one Blaster SMT timeout, found {count}")
    return source
