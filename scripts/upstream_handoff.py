#!/usr/bin/env python3
"""Mirror a lab PR's subtree commits to draft upstream PRs.

This runs from the trusted default branch in an issue_comment workflow. It reads
the PR head as Git data; it never executes files from that head.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


def git(*args: str, cwd: Path, input: bytes | None = None, env: dict | None = None) -> bytes:
    result = subprocess.run(
        ["git", *args], cwd=cwd, input=input, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, env=env, check=False,
    )
    if result.returncode:
        raise RuntimeError(f"git {args[0]} failed: {result.stderr.decode(errors='replace')[:1200]}")
    return result.stdout


def api(method: str, path: str, token: str, data: dict | None = None) -> dict | list:
    payload = json.dumps(data).encode() if data is not None else None
    req = Request(
        f"https://api.github.com/{path.lstrip('/')}", data=payload, method=method,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            **({"Content-Type": "application/json"} if payload is not None else {}),
        },
    )
    try:
        with urlopen(req, timeout=30) as response:
            return json.load(response)
    except HTTPError as exc:
        detail = exc.read().decode(errors="replace")[:1000]
        raise RuntimeError(f"GitHub {method} {path}: HTTP {exc.code}: {detail}") from exc


def source_commits(source: Path, base: str, head: str) -> list[str]:
    merge_base = git("merge-base", base, head, cwd=source).decode().strip()
    commits = git("rev-list", "--reverse", f"{merge_base}..{head}", cwd=source).decode().splitlines()
    for commit in commits:
        parents = git("rev-list", "--parents", "-n", "1", commit, cwd=source).decode().split()
        if len(parents) != 2:
            raise RuntimeError(f"source PR contains merge commit {commit[:12]}; split it manually")
    return commits


def changed_paths(source: Path, base: str, head: str, prefix: str) -> set[str]:
    merge_base = git("merge-base", base, head, cwd=source).decode().strip()
    output = git(
        "diff", "--name-only", "--no-renames", f"{merge_base}..{head}", "--", prefix,
        cwd=source,
    ).decode()
    return {line.removeprefix(prefix + "/") for line in output.splitlines()}


def commit_metadata(source: Path, commit: str) -> tuple[str, str, str, bytes]:
    output = git("show", "-s", "--format=%an%x00%ae%x00%aI%x00%B", commit, cwd=source)
    name, email, date, message = output.split(b"\0", 3)
    return name.decode(), email.decode(), date.decode(), message


def replay_commits(source: Path, target: Path, commits: list[str], prefix: str) -> list[str]:
    """Apply each source commit's path-limited patch, retaining author and message."""
    authors: list[str] = []
    for commit in commits:
        parent = git("rev-parse", f"{commit}^", cwd=source).decode().strip()
        patch = git(
            "diff", "--binary", "--no-ext-diff", "--no-renames", f"--relative={prefix}",
            parent, commit, "--", prefix, cwd=source,
        )
        if not patch:
            continue
        git("apply", "--index", "--binary", "-", cwd=target, input=patch)
        name, email, date, message = commit_metadata(source, commit)
        env = os.environ.copy()
        env.update({
            "GIT_AUTHOR_NAME": name,
            "GIT_AUTHOR_EMAIL": email,
            "GIT_AUTHOR_DATE": date,
            "GIT_COMMITTER_NAME": os.environ.get("BOT_COMMITTER_NAME", "github-actions[bot]"),
            "GIT_COMMITTER_EMAIL": os.environ.get(
                "BOT_COMMITTER_EMAIL", "41898282+github-actions[bot]@users.noreply.github.com"
            ),
        })
        git(
            "-c", "core.hooksPath=/dev/null", "-c", "commit.gpgsign=false",
            "commit", "--no-verify", "-F", "-", cwd=target, input=message, env=env,
        )
        author = f"{name} <{email}>"
        if author not in authors:
            authors.append(author)
    return authors


def source_comment(repo: str, number: int, token: str, body: str) -> None:
    api("POST", f"repos/{repo}/issues/{number}/comments", token, {"body": body})


def target_repo(source: dict) -> str:
    url = source["url"]
    prefix = "https://github.com/input-output-hk/"
    if not url.startswith(prefix) or not url.endswith(".git"):
        raise RuntimeError(f"unapproved upstream URL: {url}")
    name = url[len(prefix):-4]
    if not name or "/" in name:
        raise RuntimeError(f"unapproved upstream URL: {url}")
    return f"input-output-hk/{name}"


def mirror_target(
    source: Path, commits: list[str], base: str, head: str,
    number: int, title: str, source_repo: str, config: dict, bot_token: str,
    work: Path,
) -> str | None:
    prefix = config["path"].rstrip("/")
    expected = changed_paths(source, base, head, prefix)
    if not expected:
        return None
    repo = target_repo(config)
    branch = f"codex/lab-pr-{number}-{head[:12]}"
    existing = api(
        "GET", f"repos/{repo}/pulls?{urlencode({'state': 'all', 'head': f'input-output-hk:{branch}', 'per_page': 100})}",
        bot_token,
    )
    if existing:
        return existing[0]["html_url"]
    checkout = work / repo.split("/")[1]
    git("clone", "--branch", config["ref"], "--single-branch", config["url"], str(checkout), cwd=work)
    branch_exists = git("ls-remote", "--heads", "origin", branch, cwd=checkout)
    if branch_exists:
        raise RuntimeError(f"{repo} branch {branch} exists without a PR; refusing to overwrite it")
    pinned = config.get("rev")
    if pinned:
        git("merge-base", "--is-ancestor", pinned, "HEAD", cwd=checkout)
    git("switch", "-c", branch, cwd=checkout)
    authors = replay_commits(source, checkout, commits, prefix)
    actual = {
        line for line in git(
            "diff", "--name-only", "--no-renames", f"origin/{config['ref']}..HEAD", cwd=checkout,
        ).decode().splitlines()
    }
    if expected != actual:
        raise RuntimeError(f"{repo}: path mismatch after replay: expected {sorted(expected)}, got {sorted(actual)}")
    if not authors:
        return None
    git("push", "--set-upstream", "origin", branch, cwd=checkout)
    body = (
        f"Mirrored from https://github.com/{source_repo}/pull/{number} "
        f"at `{head}`.\n\n"
        "The commits retain their original author, author date, message, and "
        "`Co-authored-by` trailers. The bot is the committer and PR opener.\n\n"
        "Original commit authors:\n" + "".join(f"- {author}\n" for author in authors)
        + "\nReview the upstream CI and any dependency changes before merging."
    )
    created = api("POST", f"repos/{repo}/pulls", bot_token, {
        "title": f"[Lab #{number}] {title}",
        "head": branch,
        "base": config["ref"],
        "body": body,
        "draft": True,
    })
    return created["html_url"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--pr", type=int, required=True)
    parser.add_argument("--commenter", required=True)
    parser.add_argument("--source", type=Path, default=Path.cwd())
    args = parser.parse_args()
    source_token = os.environ["SOURCE_TOKEN"]
    bot_token = os.environ["BOT_TOKEN"]
    comment_token = os.environ["COMMENT_TOKEN"]
    permission = api(
        "GET", f"repos/{args.repo}/collaborators/{args.commenter}/permission", source_token,
    )
    if permission.get("permission") != "admin":
        print(f"/upstream denied: {args.commenter} is not a repository admin")
        return 0
    links: list[str] = []
    try:
        pr = api("GET", f"repos/{args.repo}/pulls/{args.pr}", source_token)
        if pr["state"] != "open":
            raise RuntimeError("source PR is not open")
        head = pr["head"]["sha"]
        base = pr["base"]["sha"]
        git("fetch", "origin", f"refs/pull/{args.pr}/head", cwd=args.source)
        fetched = git("rev-parse", "FETCH_HEAD", cwd=args.source).decode().strip()
        if fetched != head:
            raise RuntimeError("source PR changed while fetching; retry /upstream")
        git("fetch", "origin", base, cwd=args.source)
        commits = source_commits(args.source, base, head)
        manifest = json.loads((args.source / "upstreams.json").read_text())
        with tempfile.TemporaryDirectory(prefix="upstream-handoff-") as directory:
            work = Path(directory)
            for config in manifest["sources"].values():
                link = mirror_target(
                    args.source, commits, base, head, args.pr, pr["title"],
                    args.repo, config, bot_token, work,
                )
                if link:
                    links.append(link)
    except Exception as exc:
        completed = "\nAlready opened:\n" + "\n".join(f"- {link}" for link in links) if links else ""
        try:
            source_comment(args.repo, args.pr, comment_token,
                           f"`/upstream` stopped: {str(exc)[:1500]}{completed}")
        except Exception as comment_exc:
            print(f"Could not report handoff failure on source PR: {comment_exc}", file=sys.stderr)
        raise
    if links:
        source_comment(args.repo, args.pr, comment_token,
                       f"Upstream drafts for source commit `{head}`:\n" +
                       "\n".join(f"- {link}" for link in links))
    else:
        source_comment(args.repo, args.pr, comment_token,
                       "`/upstream` found no changes under configured upstream paths.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
