import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import combine_search_shards
import replay_batches


class CombineSearchShardsTests(unittest.TestCase):
    def test_combined_run_is_complete_and_replay_compatible(self):
        hashes = [character * 56 for character in "abcde"]
        budgets = {script_hash: 2000 for script_hash in hashes}
        revision = "f" * 40
        active = {"cohort": "2026-11-23", "config": "search-config", "smt_timeout": 20}
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shards = root / "shards"
            shards.mkdir()
            live = root / "LiveScripts"
            (live / "cohorts").mkdir(parents=True)
            (live / "cohorts/2026-11-23.json").write_text(
                json.dumps({"script_hashes": hashes}))
            for index in range(2):
                artifact = shards / f"cardano-benchmark-shard-42-{index}"
                artifact.mkdir()
                run_id = f"shard-{index}"
                assignment = hashes[index::2]
                rows = [{"script_hash": script_hash, "status": "candidate",
                         "cek_fuel": 2000, "revision": revision,
                         "config": active["config"], "run_id": run_id}
                        for script_hash in assignment]
                latest = {row["script_hash"]: {
                    "status": row["status"], "cek_fuel": 2000,
                    "config": active["config"], "run_id": run_id}
                    for row in rows}
                (artifact / "active-config.json").write_text(json.dumps(active))
                (artifact / "latest.json").write_text(json.dumps(latest))
                (artifact / f"{run_id}.jsonl").write_text(
                    "".join(json.dumps(row) + "\n" for row in rows))
            output = root / "combined"
            result = combine_search_shards.combine(
                shards, hashes, budgets, {}, revision, "42", 2, 0, output)
            self.assertEqual(result["scripts"], 5)
            self.assertEqual(result["run_id"], "full-42")
            with patch.object(replay_batches, "LIVE", live):
                path, _, rows, cohort = replay_batches.search_run(output, revision)
            self.assertEqual(path.name, "full-42.jsonl")
            self.assertEqual(cohort, hashes)
            self.assertEqual(len(rows), 5)
            for index in range(2):
                result_file = shards / f"cardano-benchmark-shard-42-{index}/shard-{index}.jsonl"
                result_file.write_text(result_file.read_text().split("\n", 1)[0] + "\n")
            limited = root / "limited"
            combine_search_shards.combine(
                shards, hashes, budgets, {}, revision, "42", 2, 1, limited)
            with patch.object(replay_batches, "LIVE", live):
                with self.assertRaises(replay_batches.IncompleteCohort):
                    replay_batches.search_run(limited, revision)
            (shards / "cardano-benchmark-shard-42-1/shard-1.jsonl").write_text("")
            with self.assertRaisesRegex(ValueError, "exact assignment"):
                combine_search_shards.combine(
                    shards, hashes, budgets, {}, revision, "42", 2, 0, output)


if __name__ == "__main__":
    unittest.main()
