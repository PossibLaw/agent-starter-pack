#!/usr/bin/env python3
"""PreToolUse hook for Bash — blocks destructive commands, escalates risky ones,
and refuses `git commit` while the shared .agent/HANDOFF.md is untracked or unstaged."""

import json
import re
import shlex
import subprocess
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from blacklist import BLOCKED_PATTERNS, ESCALATE_PATTERNS

# Shared continuity file that must ship with every commit that changes it.
HANDOFF_REL = ".agent/HANDOFF.md"
_SHELL_OPERATORS = {"&&", "||", ";", ";;", "|", "|&", "&"}
_GIT_GLOBAL_OPTS_WITH_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}


def _tokenize(command):
    """Split a shell command into tokens, keeping quoted strings intact and
    surfacing operators (&&, ||, ;, |) as their own tokens."""
    lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    try:
        return list(lexer)
    except ValueError:
        return command.split()


def _segments(tokens):
    """Group tokens into simple commands separated by shell operators."""
    segments, current = [], []
    for tok in tokens:
        if tok in _SHELL_OPERATORS:
            if current:
                segments.append(current)
            current = []
        else:
            current.append(tok)
    if current:
        segments.append(current)
    return segments


def _parse_git_segment(segment):
    """Return (subcommand, args, chdir) for a `git ...` segment, else None."""
    if not segment or segment[0] != "git":
        return None
    chdir = None
    i = 1
    while i < len(segment):
        tok = segment[i]
        if tok in _GIT_GLOBAL_OPTS_WITH_ARG and i + 1 < len(segment):
            if tok == "-C":
                chdir = segment[i + 1]
            i += 2
            continue
        if tok.startswith("-"):
            i += 1
            continue
        return tok, segment[i + 1 :], chdir
    return None


def _run_git(repo_dir, *args):
    try:
        proc = subprocess.run(
            ["git", "-C", repo_dir, *args],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout


def _abs_path_covers(tok_abs, handoff_abs):
    """Is the handoff the same file as tok_abs, or inside that directory? Compared by
    inode so symlinked checkouts and case-insensitive filesystems behave."""
    if not os.path.exists(tok_abs):
        return False
    current = handoff_abs
    while True:
        try:
            if os.path.samefile(tok_abs, current):
                return True
        except OSError:
            return False
        parent = os.path.dirname(current)
        if parent == current:
            return False
        current = parent


def _add_covers(add_args, add_dir, toplevel, untracked):
    """Does `git add <add_args>` (run from add_dir) stage the handoff? Untracked files
    are only picked up by explicit paths, `.`/`:/`, or -A/--all — never by -u/--update.
    Relative pathspecs are resolved the way git does: relative to add_dir's prefix
    inside the repo, so no raw path strings are ever compared."""
    prefix = _run_git(add_dir, "rev-parse", "--show-prefix")
    if prefix is None:
        return False
    prefix = prefix.strip()
    handoff_from_add_dir = os.path.relpath(HANDOFF_REL, prefix) if prefix else HANDOFF_REL
    handoff_abs = os.path.join(toplevel, *HANDOFF_REL.split("/"))
    for tok in add_args:
        if tok in ("-A", "--all", "--no-ignore-removal"):
            return True
        if tok in ("-u", "--update"):
            if not untracked:
                return True
            continue
        if tok.startswith("-"):
            continue
        if tok in (":/", ":/."):
            return True
        if os.path.isabs(tok):
            if _abs_path_covers(tok, handoff_abs):
                return True
            continue
        norm = os.path.normpath(tok)
        if norm == ".":
            if not handoff_from_add_dir.startswith(".."):
                return True
            continue
        if norm == handoff_from_add_dir or handoff_from_add_dir.startswith(norm + "/"):
            return True
    return False


def _commit_includes_all(commit_args):
    """`git commit -a` / `--all` (also combined short flags like -am) stages
    modified tracked files, but never untracked ones."""
    for tok in commit_args:
        if tok == "--all":
            return True
        if tok.startswith("-") and not tok.startswith("--") and "a" in tok[1:]:
            return True
    return False


def check_handoff_commit(command, cwd):
    """Return a BLOCKED message when `git commit` would leave the shared
    handoff untracked or with unstaged edits; otherwise None.

    Never raises: any unexpected condition (not a git repo, no handoff file,
    git unavailable) means the commit is allowed."""
    try:
        tokens = _tokenize(command)
        segments = _segments(tokens)
        base_dir = cwd or os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()

        add_segments = []
        for segment in segments:
            parsed = _parse_git_segment(segment)
            if not parsed:
                continue
            sub, args, chdir = parsed
            repo_dir = os.path.normpath(os.path.join(base_dir, chdir)) if chdir else base_dir
            if sub == "add":
                add_segments.append((args, repo_dir))
                continue
            if sub != "commit":
                continue

            toplevel = _run_git(repo_dir, "rev-parse", "--show-toplevel")
            if not toplevel:
                return None
            toplevel = toplevel.strip()
            handoff_abs = os.path.join(toplevel, *HANDOFF_REL.split("/"))
            if not os.path.isfile(handoff_abs):
                return None

            status = _run_git(toplevel, "status", "--porcelain", "--untracked-files=all", "--", HANDOFF_REL)
            if status is None or not status.strip():
                return None
            xy = status.splitlines()[0][:2]
            untracked = xy == "??"
            unstaged_edit = (not untracked) and xy[1] == "M"
            if not (untracked or unstaged_edit):
                return None

            staged_inline = any(
                _add_covers(add_args, add_dir, toplevel, untracked) for add_args, add_dir in add_segments
            )
            if staged_inline:
                return None
            if unstaged_edit and _commit_includes_all(args):
                return None

            if untracked:
                return (
                    f"BLOCKED: {HANDOFF_REL} is untracked, so this commit would leave the shared "
                    f"handoff behind. Refresh the Current Baton, then run: "
                    f"git add {HANDOFF_REL} -- and retry the commit."
                )
            return (
                f"BLOCKED: {HANDOFF_REL} has unstaged edits, so this commit would ship a stale "
                f"handoff. Run: git add {HANDOFF_REL} -- then retry the commit (or use git commit -a)."
            )
        return None
    except Exception:  # noqa: BLE001 - a guardrail must never break the tool call
        return None


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    # Check blocked patterns first
    for pattern in BLOCKED_PATTERNS:
        if re.search(pattern, command):
            print(
                f"BLOCKED: Command matches destructive pattern '{pattern}'. "
                f"Use a safer alternative.",
                file=sys.stderr,
            )
            sys.exit(2)

    # Shared handoff must ship with the work it describes
    handoff_block = check_handoff_commit(command, data.get("cwd"))
    if handoff_block:
        print(handoff_block, file=sys.stderr)
        sys.exit(2)

    # Check escalation patterns
    for pattern in ESCALATE_PATTERNS:
        if re.search(pattern, command):
            result = {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": (
                        f"This command may have unintended consequences "
                        f"(matched pattern '{pattern}'). Confirm before proceeding."
                    ),
                }
            }
            print(json.dumps(result))
            sys.exit(0)

    # Safe command — approve
    sys.exit(0)


if __name__ == "__main__":
    main()
