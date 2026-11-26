import unittest
from unittest.mock import patch

from benchmark import classify, error_report, run_case, shard_hashes
from fuel_budgets import ROOT, load_budgets, property_at_fuel, property_at_smt_timeout


class ClassificationTests(unittest.TestCase):
    def test_shards_cover_each_script_once(self):
        hashes = list(load_budgets())
        shards = [shard_hashes(hashes, index, 16) for index in range(16)]
        self.assertEqual(sum(map(len, shards)), len(hashes))
        self.assertEqual(set().union(*map(set, shards)), set(hashes))
        self.assertLessEqual(max(map(len, shards)) - min(map(len, shards)), 1)

    def test_every_catalogued_script_has_an_individual_budget(self):
        budgets = load_budgets()
        self.assertEqual(len(budgets), 2250)
        self.assertTrue(all(1 <= fuel <= 100000 for fuel in budgets.values()))

    def test_property_fuel_can_change_for_every_script(self):
        for script_hash in load_budgets():
            source = (ROOT / f"S_{script_hash}/Properties.lean").read_text()
            changed = property_at_fuel(source, 3000)
            self.assertIn("CEK fuel: 3000", changed)
            self.assertIn(" 3000)]", changed)
            self.assertNotIn(" 1000)]", changed)
            self.assertIn("#blaster (timeout: 20)", property_at_smt_timeout(changed, 20))

    def test_run_case_records_selected_fuel(self):
        script_hash = next(iter(load_budgets()))
        calls = []

        def command(argv, timeout, env):
            calls.append(argv)
            if argv[1] == "lean":
                from pathlib import Path
                property_source = Path(argv[2]).read_text()
                self.assertIn(" 3000)]", property_source)
                self.assertIn("#blaster (timeout: 20)", property_source)
                return 0, "✅ Expected Falsified\nCounterexample:", "", False
            return 0, "", "", False

        with patch("benchmark.run_command", side_effect=command):
            result = run_case(script_hash, 25, {}, 3000)
        self.assertEqual(result["status"], "candidate")
        self.assertEqual(result["cek_fuel"], 3000)
        self.assertEqual(result["smt_timeout_seconds"], 20)
        self.assertEqual([call[1] for call in calls], ["build", "lean"])

    def test_unexpected_valid_is_inconclusive_at_fixed_cek_fuel(self):
        self.assertEqual(classify(1, "error: ❌ Unexpected Valid", False), "unknown")

    def test_solver_error_remains_an_error(self):
        self.assertEqual(classify(1, "Unexpected smt error", False), "error")

    def test_wall_timeout_wins(self):
        self.assertEqual(classify(None, "error: ❌ Unexpected Valid", True), "timeout")

    def test_error_report_keeps_diagnostic_without_build_trace(self):
        script_hash = "a" * 56
        result = {
            "script_hash": script_hash, "run_id": "run", "exit_code": 1,
            "stdout": ("trace: local build path\n"
                       f"error: LiveScripts/S_{script_hash}/Script.lean:3:0: "
                       "maximum recursion depth has been reached\n"
                       "use `set_option maxRecDepth <num>` to increase limit\n"
                       "Some required targets logged failures:\n"),
            "stderr": "",
        }
        report = error_report(result)
        self.assertEqual(report["kind"], "recursion_depth")
        self.assertEqual(report["message"], "maximum recursion depth has been reached")
        self.assertNotIn("local build path", report["details"])


if __name__ == "__main__":
    unittest.main()
