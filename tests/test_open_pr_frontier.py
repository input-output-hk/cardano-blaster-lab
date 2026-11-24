import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

from scripts import open_pr_frontier


def load_dashboard_builder():
    path = Path(__file__).resolve().parents[1] / "benchmark/cardano-dashboard/build.py"
    spec = importlib.util.spec_from_file_location("dashboard_build", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class OpenPRFrontierTest(unittest.TestCase):
    def test_only_strict_gains_in_same_cohort(self):
        dashboard = load_dashboard_builder()
        events = dashboard.open_pr_events(
            [
                {"number": 44, "verified_hashes": ["a", "b", "c", "outside"],
                 "head_sha": "1" * 40, "checked_at": "2026-11-24T12:00:00Z",
                 "title": "Open gain", "author": "test", "pr_url": "https://example.com/pr",
                 "replay_url": "https://example.com/replay"},
                {"number": 45, "verified_hashes": ["a", "b", "b", "outside"]},
            ],
            {"cohort": {"a", "b", "c"}, "other": {"outside"}},
            {"a": {}, "b": {}, "outside": {}},
            [{"cohort": "cohort", "solved_count": 2}],
        )
        self.assertEqual(len(events), 1)
        self.assertTrue(events[0]["open_pr"])
        self.assertEqual(events[0]["solved_count"], 3)
        self.assertEqual(events[0]["gained"], 1)
        self.assertEqual(events[0]["prs"][0]["number"], 44)

    def test_requires_successful_replay_for_this_revision(self):
        sha = "1" * 40
        with patch.object(open_pr_frontier, "api", return_value={"workflow_runs": [
                {"head_sha": "2" * 40, "pull_requests": [{"number": 44}]},
                {"head_sha": sha, "pull_requests": [{"number": 45}]},
        ]}) as call:
            self.assertIsNone(open_pr_frontier.replay_run("org/repo", 44, sha))
            self.assertEqual(call.call_count, 1)

        run = {"head_sha": sha, "pull_requests": [{"number": 44}], "id": 12}
        job = {"name": "benchmark", "html_url": "https://example.com/replay", "steps": [
            {"name": open_pr_frontier.REPLAY_STEP, "conclusion": "success",
             "completed_at": "2026-11-24T12:00:00Z"}
        ]}
        with patch.object(open_pr_frontier, "api",
                          side_effect=[{"workflow_runs": [run]}, [{"jobs": [job]}]]):
            self.assertEqual(open_pr_frontier.replay_run("org/repo", 44, sha)["url"],
                             "https://example.com/replay")

    def test_solver_candidates_are_excluded(self):
        self.assertEqual(open_pr_frontier.verified_hashes({
            "a" * 56: {"status": "candidate"},
            "b" * 56: {"status": "verified",
                       "checks": ["valid_context", "is_data_roundtrip", "cek_halt_fuel_1000"]},
            "c" * 56: {"status": "verified", "checks": ["valid_context", {}]},
        }), {"b" * 56})


if __name__ == "__main__":
    unittest.main()
