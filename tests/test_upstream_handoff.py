"""Local Git fixtures for the admin-only upstream handoff workflow."""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts import upstream_handoff as handoff


def git(repo: Path, *args: str, env: dict | None = None) -> str:
    result = subprocess.run(
        ["git", *args], cwd=repo, env=env, check=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
    )
    return result.stdout.strip()


def commit(repo: Path, message: str, author: str, email: str, date: str) -> str:
    git(repo, "add", ".")
    env = os.environ.copy()
    env.update({
        "GIT_AUTHOR_NAME": author,
        "GIT_AUTHOR_EMAIL": email,
        "GIT_AUTHOR_DATE": date,
        "GIT_COMMITTER_NAME": "Fixture Committer",
        "GIT_COMMITTER_EMAIL": "committer@example.com",
    })
    git(repo, "commit", "-m", message, env=env)
    return git(repo, "rev-parse", "HEAD")


class UpstreamHandoffTests(unittest.TestCase):
    def test_replays_only_target_subtree_and_retains_authors(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            target = root / "target"
            source.mkdir()
            target.mkdir()
            for repo in (source, target):
                git(repo, "init", "-b", "main")
                git(repo, "config", "user.name", "Fixture Committer")
                git(repo, "config", "user.email", "committer@example.com")

            (source / "packages/One").mkdir(parents=True)
            (source / "packages/Two").mkdir(parents=True)
            (source / "packages/One/a.txt").write_text("before\n")
            (source / "packages/Two/b.txt").write_text("before\n")
            commit(source, "Import trees", "Importer", "importer@example.com", "2024-01-01T00:00:00+00:00")
            git(source, "switch", "-c", "feature")
            (source / "packages/One/a.txt").write_text("after\n")
            (source / "packages/Two/b.txt").write_text("unrelated\n")
            first = commit(
                source, "Improve solver\n\nCo-authored-by: Bob <bob@example.com>",
                "Alice", "alice@example.com", "2024-02-01T00:00:00+00:00",
            )
            (source / "packages/One/new.txt").write_text("new\n")
            second = commit(source, "Add case", "Carol", "carol@example.com", "2024-02-02T00:00:00+00:00")
            git(source, "switch", "main")
            (source / "packages/Two/base-only.txt").write_text("later\n")
            base = commit(source, "Advance base", "Base Author", "base@example.com", "2024-02-03T00:00:00+00:00")

            (target / "a.txt").write_text("before\n")
            commit(target, "Target baseline", "Importer", "importer@example.com", "2024-01-01T00:00:00+00:00")

            commits = handoff.source_commits(source, base, second)
            self.assertEqual(commits, [first, second])
            self.assertEqual(handoff.changed_paths(source, base, second, "packages/One"), {"a.txt", "new.txt"})
            authors = handoff.replay_commits(source, target, commits, "packages/One")
            self.assertEqual(authors, ["Alice <alice@example.com>", "Carol <carol@example.com>"])
            self.assertEqual((target / "a.txt").read_text(), "after\n")
            self.assertEqual((target / "new.txt").read_text(), "new\n")
            self.assertFalse((target / "b.txt").exists())
            self.assertEqual(git(target, "log", "-2", "--format=%an <%ae>" ).splitlines(), [
                "Carol <carol@example.com>", "Alice <alice@example.com>",
            ])
            self.assertEqual(git(target, "log", "-1", "--format=%cn <%ce>"),
                             "github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>")
            self.assertIn("Co-authored-by: Bob <bob@example.com>",
                          git(target, "log", "-2", "--format=%B"))
            self.assertEqual(git(target, "show", "-s", "--format=%aI", "HEAD~1"),
                             "2024-02-01T00:00:00Z")

    def test_rejects_unapproved_target(self) -> None:
        with self.assertRaisesRegex(RuntimeError, "unapproved upstream URL"):
            handoff.target_repo({"url": "https://github.com/another-owner/repo.git"})


if __name__ == "__main__":
    unittest.main()
