import unittest
import json
from pathlib import Path

from fuel_budgets import property_at_smt_timeout
from plan_fuel_budgets import plan
from probe_fuel_budgets import selected_cases


class FuelPlanTests(unittest.TestCase):
    def test_probe_rewrites_only_the_smt_limit(self):
        source = "#blaster (timeout: 10) (verbose: 1)\n"
        self.assertEqual(property_at_smt_timeout(source, 20),
                         "#blaster (timeout: 20) (verbose: 1)\n")
        with self.assertRaises(ValueError):
            property_at_smt_timeout("#blaster (verbose: 1)\n", 20)

    def test_every_unexpected_valid_case_has_more_fuel(self):
        root = Path(__file__).resolve().parent
        latest = json.loads((root / "results/latest.json").read_text())
        budgets = json.loads((root / "fuel-budgets.json").read_text())["scripts"]
        unexpected = {script_hash: row.get("cek_fuel", 1000)
                      for script_hash, row in latest.items()
                      if row["note"].startswith("No counterexample at CEK fuel ")}
        self.assertTrue(all(budgets[script_hash] > fuel for script_hash, fuel in unexpected.items()
                            if fuel < 100000))
        selected = selected_cases(10, 40)
        self.assertTrue(all(script_hash in unexpected for script_hash, _ in selected))

    def test_candidates_and_unresolved_cases_keep_distinct_evidence(self):
        hashes = {key: key * 56 for key in "abcdefgh"}
        catalog = [
            {"script_hash": value, "serialised_size": 100, "cluster_id": "family" if key in "de" else key}
            for key, value in hashes.items()
        ]
        latest = {
            hashes["a"]: {"status": "candidate", "run_id": "baseline"},
            hashes["b"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
            hashes["c"]: {"status": "timeout", "timeout_stage": "elaboration"},
            hashes["d"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
            hashes["e"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
            hashes["f"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
            hashes["g"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
            hashes["h"]: {"status": "unknown", "note": "No counterexample at CEK fuel 1000; a higher fuel limit may reveal one."},
        }
        observations = [
            {"script_hash": hashes["d"], "cek_fuel": 2600, "status": "candidate", "source": "probe"},
            {"script_hash": hashes["f"], "cek_fuel": 2000, "status": "timeout", "source": "probe"},
            {"script_hash": hashes["g"], "cek_fuel": 2000, "status": "unknown", "outcome": "no_counterexample", "source": "probe"},
            {"script_hash": hashes["g"], "cek_fuel": 4000, "status": "timeout", "source": "probe"},
            {"script_hash": hashes["h"], "cek_fuel": 2000, "status": "unknown", "outcome": "solver_unknown", "source": "probe"},
        ]
        budgets, report = plan(catalog, latest, observations, {})
        self.assertEqual(budgets, {
            hashes["a"]: 1000, hashes["b"]: 2000, hashes["c"]: 1000,
            hashes["d"]: 2600, hashes["e"]: 2600, hashes["f"]: 2000,
            hashes["g"]: 4000, hashes["h"]: 2000,
        })
        self.assertEqual(report["scripts"][hashes["c"]]["basis"], "wall_timeout")
        self.assertEqual(report["scripts"][hashes["e"]]["basis"], "structural_peer_probe")
        self.assertEqual(report["scripts"][hashes["f"]]["basis"], "higher_fuel_timeout")
        self.assertEqual(report["scripts"][hashes["g"]]["basis"], "higher_fuel_timeout")
        self.assertEqual(report["scripts"][hashes["h"]]["basis"], "unknown_at_probe")


if __name__ == "__main__":
    unittest.main()
