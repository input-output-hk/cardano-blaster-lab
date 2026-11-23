import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import error_agent


class ErrorAgentTests(unittest.TestCase):
    def test_only_current_run_errors_are_reported(self):
        script_hash = "a" * 56
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "active-config.json").write_text(json.dumps({"config": "current"}))
            rows = [
                {"script_hash": script_hash, "status": "error", "config": "current",
                 "timestamp": "2026-11-23T16:00:00Z"},
                {"script_hash": script_hash, "status": "error", "config": "old",
                 "timestamp": "2026-11-23T18:00:00Z"},
                {"script_hash": script_hash, "status": "timeout", "config": "current",
                 "timestamp": "2026-11-23T18:00:00Z"},
                {"script_hash": script_hash, "status": "error", "config": "current",
                 "timestamp": "2026-11-23T18:00:00Z", "stdout": "first"},
                {"script_hash": script_hash, "status": "error", "config": "current",
                 "timestamp": "2026-11-23T18:01:00Z", "stdout": "latest"},
            ]
            (root / "results.jsonl").write_text("\n".join(json.dumps(row) for row in rows))
            errors, active = error_agent.current_errors(root, {"created_at": "2026-11-23T17:00:00Z"})
            self.assertEqual(active["config"], "current")
            self.assertEqual(len(errors), 1)
            self.assertEqual(errors[0]["stdout"], "latest")

    def test_error_signature_and_secret_redaction(self):
        row = {"stdout": "error: LiveScripts/S_test/Script.lean:3:0: maximum recursion depth has been reached",
               "stderr": "error: build failed"}
        self.assertEqual(error_agent.first_error(row), "maximum recursion depth has been reached")
        self.assertEqual(error_agent.redact("sk-" + "A" * 30), "[redacted API key]")

    def test_repeat_run_does_not_create_another_issue(self):
        script_hash = "b" * 56
        issue = {"number": 4, "state": "open", "html_url": "https://github.com/o/r/issues/4",
                 "body": "https://github.com/o/r/actions/runs/7"}
        data = {"script_hash": script_hash, "run_url": "https://github.com/o/r/actions/runs/7"}
        with patch.object(error_agent, "gh", side_effect=AssertionError("unexpected GitHub write")):
            action, url = error_agent.post_issue("o/r", data, "body", {script_hash: issue})
        self.assertEqual((action, url), ("unchanged", issue["html_url"]))


if __name__ == "__main__":
    unittest.main()
