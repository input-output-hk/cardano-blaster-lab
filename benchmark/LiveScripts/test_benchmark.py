import unittest

from benchmark import classify, error_report, property_at_fuel


class ClassificationTests(unittest.TestCase):
    def test_generated_property_uses_requested_fuel(self):
        script_hash = "a" * 56
        source = ("-- Search purpose: spend; CEK fuel: 1000; SMT limit: 10 seconds.\n"
                  f"¬ isSuccessful (cekExecuteProgram script_{script_hash}.script "
                  "(spendingInputs input) 1000)]\n")
        changed = property_at_fuel(source, 3000)
        self.assertIn("CEK fuel: 3000", changed)
        self.assertIn("(spendingInputs input) 3000)]", changed)
        with self.assertRaisesRegex(ValueError, "expected one generated CEK call"):
            property_at_fuel(source + source, 3000)

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
