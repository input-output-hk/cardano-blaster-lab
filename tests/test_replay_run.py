import importlib.util
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch


LIVE = Path(__file__).resolve().parents[1] / "benchmark/LiveScripts"
sys.path.insert(0, str(LIVE))
spec = importlib.util.spec_from_file_location("replay_run", LIVE / "replay_run.py")
replay_run = importlib.util.module_from_spec(spec)
spec.loader.exec_module(replay_run)


class ReplayRunTest(unittest.TestCase):
    def test_uses_model_from_same_run(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "results").mkdir()
            (root / "results/active-config.json").write_text(json.dumps({"config": "config"}))
            script_hash = "a" * 56
            (root / "catalog.json").write_text(json.dumps({"scripts": [
                {"script_hash": script_hash, "serialised_size": 18},
            ]}))
            directory = root / f"S_{script_hash}"
            directory.mkdir()
            (directory / "metadata.json").write_text(json.dumps({
                "script_hash": script_hash, "script_type": "plutusV2", "search_purpose": "mint",
            }))
            verified = root / "results/verified.json"
            verified.write_text("{}")
            output = "✅ Expected Falsified\nCounterexample:\n - input: (example : MintingInput)\ninfo: done\n"
            results = root / "run.jsonl"
            results.write_text(json.dumps({
                "script_hash": script_hash, "status": "candidate", "config": "config",
                "revision": "1" * 40, "run_id": "run-1", "stdout": output,
            }) + "\n")
            def save_model(*_, **__):
                source = "def replayInput : MintingInput := example\n"
                (directory / "ReplayWitness.lean").write_text(source)
                verified.write_text(json.dumps({script_hash: {
                    "witness_sha256": hashlib.sha256(source.encode()).hexdigest(),
                }}))
                return "verified"

            with patch.object(replay_run, "ROOT", root), \
                 patch.object(replay_run, "OUTPUT", verified), \
                 patch.object(replay_run.subprocess, "check_output", return_value="1" * 40), \
                 patch.object(replay_run, "save_witness", side_effect=save_model) as save:
                summary = replay_run.replay(results, 12, 1000, "2" * 40)
            self.assertEqual(summary["newly_verified"], 1)
            self.assertEqual(summary["head_sha"], "2" * 40)
            self.assertEqual(save.call_args.args[:2], (script_hash, "(example : MintingInput)"))
            self.assertEqual(save.call_args.kwargs["baseline_run_id"], "run-1")
            evidence = json.loads((root / "results/replay-evidence.json").read_text())
            self.assertIn(script_hash, evidence)

    def test_rejects_stale_results(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "results").mkdir()
            (root / "results/active-config.json").write_text(json.dumps({"config": "current"}))
            results = root / "run.jsonl"
            results.write_text(json.dumps({"config": "old", "revision": "1" * 40,
                                           "run_id": "run-1"}) + "\n")
            with patch.object(replay_run, "ROOT", root), \
                 patch.object(replay_run.subprocess, "check_output", return_value="1" * 40):
                with self.assertRaisesRegex(ValueError, "does not match"):
                    replay_run.replay(results, 12, 1000)


if __name__ == "__main__":
    unittest.main()
