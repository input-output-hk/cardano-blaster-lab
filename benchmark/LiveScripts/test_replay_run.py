import json
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest.mock import patch

import replay_run


class ReplayFuelTests(unittest.TestCase):
    def test_each_candidate_replays_at_its_search_fuel(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "results").mkdir()
            (root / "results/active-config.json").write_text(json.dumps({"config": "same-run"}))
            (root / "results/verified.json").write_text("{}")
            hashes = ["a" * 56, "b" * 56]
            (root / "catalog.json").write_text(json.dumps({
                "scripts": [{"script_hash": h, "serialised_size": i} for i, h in enumerate(hashes)]
            }))
            rows = []
            for script_hash, fuel in zip(hashes, (1000, 3000)):
                case = root / f"S_{script_hash}"
                case.mkdir()
                (case / "metadata.json").write_text(json.dumps({"script_type": "plutusV3"}))
                row = {"script_hash": script_hash, "status": "candidate", "stdout": "model",
                       "config": "same-run", "revision": "c" * 40, "run_id": "run"}
                if fuel != 1000:
                    row["cek_fuel"] = fuel
                rows.append(row)
            results = root / "results/search.jsonl"
            results.write_text("\n".join(json.dumps(row) for row in rows) + "\n")
            with (patch.object(replay_run, "ROOT", root),
                  patch.object(replay_run, "OUTPUT", root / "results/verified.json"),
                  patch.object(replay_run.subprocess, "check_output", return_value="c" * 40),
                  patch.object(replay_run, "witness_type", return_value=("ScriptContext", "ctx", "replayContext")),
                  patch.object(replay_run, "typed_model", return_value="model"),
                  patch.object(replay_run, "save_witness", return_value="verified") as save):
                with redirect_stdout(StringIO()):
                    summary = replay_run.replay(results, 0)
            self.assertEqual(summary["cek_fuels"], [1000, 3000])
            self.assertEqual([call.args[2] for call in save.call_args_list], [1000, 3000])


if __name__ == "__main__":
    unittest.main()
