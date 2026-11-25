import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "benchmark" / "LiveScripts"))
import verify_replays


class ReplayScopeTests(unittest.TestCase):
    HASH = "86ae9eebd8b97944a45201e4aec1330a72291af2d071644bba015959"

    def test_witness_only_changes_select_one_replay(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "benchmark" / "LiveScripts" / f"S_{self.HASH}" / "ReplayWitness.lean"
            path.parent.mkdir(parents=True)
            path.write_text("-- test witness\n")
            with patch.object(verify_replays, "BENCHMARK", root / "benchmark"):
                self.assertEqual(verify_replays.select_changed_witnesses([
                    f"benchmark/LiveScripts/S_{self.HASH}/ReplayWitness.lean",
                    "benchmark/LiveScripts/results/verified.json",
                    "benchmark/cardano-dashboard/runs.json",
                ]), {self.HASH})

    def test_core_change_forces_full_replay(self):
        self.assertIsNone(verify_replays.select_changed_witnesses([
            "packages/PlutusCoreBlaster/PlutusCore/UPLC/CekMachine.lean",
        ]))
        self.assertIsNone(verify_replays.select_changed_witnesses([
            "benchmark/LiveScripts/verify_replays.py",
        ]))

    def test_deleted_witness_forces_full_replay(self):
        missing_hash = "0" * 56
        self.assertIsNone(verify_replays.select_changed_witnesses([
            f"benchmark/LiveScripts/S_{missing_hash}/ReplayWitness.lean",
        ]))

    def test_committed_inventory_matches_all_witness_files(self):
        stored = json.loads(verify_replays.OUTPUT.read_text())
        inventory = dict(verify_replays.verify(path, replay=False)
                         for path in verify_replays.ROOT.glob("S_*/ReplayWitness.lean"))
        self.assertEqual(inventory, stored)


if __name__ == "__main__":
    unittest.main()
