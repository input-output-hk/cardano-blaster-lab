import unittest

from benchmark import classify


class ClassificationTests(unittest.TestCase):
    def test_unexpected_valid_is_inconclusive_at_fixed_cek_fuel(self):
        self.assertEqual(classify(1, "error: ❌ Unexpected Valid", False), "unknown")

    def test_solver_error_remains_an_error(self):
        self.assertEqual(classify(1, "Unexpected smt error", False), "error")

    def test_wall_timeout_wins(self):
        self.assertEqual(classify(None, "error: ❌ Unexpected Valid", True), "timeout")


if __name__ == "__main__":
    unittest.main()
