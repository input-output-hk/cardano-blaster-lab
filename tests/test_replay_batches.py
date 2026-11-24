import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("replay_batches", ROOT / "scripts/replay_batches.py")
replay_batches = importlib.util.module_from_spec(spec)
spec.loader.exec_module(replay_batches)


class ReplayBatchesTest(unittest.TestCase):
    def test_all_candidates_are_assigned_and_aggregated(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            live = root / "benchmark/LiveScripts"
            (live / "cohorts").mkdir(parents=True)
            (live / "results").mkdir()
            search = root / "search"
            search.mkdir()
            hashes = [f"{i:056x}" for i in range(17)]
            revision = "a" * 40
            config = "config"
            rows = [{"script_hash": h, "status": "candidate", "revision": revision,
                     "config": config, "run_id": "run-1"} for h in hashes]
            (live / "cohorts/2026-11-23.json").write_text(json.dumps({"script_hashes": hashes}))
            (live / "catalog.json").write_text(json.dumps({"scripts": [
                {"script_hash": h, "serialised_size": i} for i, h in enumerate(hashes)
            ]}))
            (live / "results/verified.json").write_text("{}")
            (search / "run.jsonl").write_text("".join(json.dumps(row) + "\n" for row in rows))
            (search / "active-config.json").write_text(json.dumps({
                "config": config, "cohort": "2026-11-23",
            }))
            (search / "latest.json").write_text(json.dumps({
                h: {"config": config} for h in hashes
            }))
            shards = root / "shards"
            shards.mkdir()
            with patch.object(replay_batches, "LIVE", live):
                plan_file = root / "github-output"
                self.assertEqual(replay_batches.plan(search, revision, 16, plan_file),
                                 {"eligible": True, "pending": 17, "shards": 2})
                self.assertIn('"index":1', plan_file.read_text())
                for index in range(2):
                    assigned = hashes[index::2]
                    records = {}
                    evidence = {}
                    for h in assigned:
                        directory = live / f"S_{h}"
                        directory.mkdir()
                        witness = f"def replayInput := {h}\n"
                        (directory / "ReplayWitness.lean").write_text(witness)
                        (directory / "ReplayWitness.json").write_text(json.dumps({"script_hash": h}))
                        records[h] = {
                            "status": "verified",
                            "checks": ["valid_context", "is_data_roundtrip", "cek_halt_fuel_1000"],
                            "witness_sha256": hashlib.sha256(witness.encode()).hexdigest(),
                        }
                        evidence[h] = witness
                    work = root / f"work-{index}"
                    work.mkdir()
                    summary = {
                        "run_id": "run-1", "revision": revision, "head_sha": revision,
                        "config": config,
                        "shard_index": index, "shard_count": 2,
                        "shard_pending": len(assigned), "attempted": len(assigned),
                        "skipped_due_to_limit": 0,
                        "outcomes": {h: "verified" for h in assigned},
                    }
                    for name, value in (("replay-summary.json", summary),
                                        ("verified.json", records),
                                        ("replay-evidence.json", evidence)):
                        (work / name).write_text(json.dumps(value))
                    replay_batches.stage(work / "replay-summary.json",
                                         work / "verified.json",
                                         work / "replay-evidence.json",
                                         shards / f"cardano-replay-shard-42-{index}")
                result = replay_batches.aggregate(search, shards, revision, root / "combined")
                self.assertEqual(result, {"attempted": 17, "newly_verified": 17})
                merged = json.loads((root / "combined/benchmark/LiveScripts/results/verified.json").read_text())
                self.assertEqual(set(merged), set(hashes))
                (shards / "cardano-replay-shard-42-1/replay-summary.json").unlink()
                with self.assertRaises((ValueError, FileNotFoundError)):
                    replay_batches.aggregate(search, shards, revision, root / "incomplete")


if __name__ == "__main__":
    unittest.main()
