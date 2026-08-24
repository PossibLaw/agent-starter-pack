---
description: Manage and view active Claude Code guardrails and safety hooks (PossibNow Dev Harness).
argument-hint: [optional status or rule check]
allowed-tools: Read
---

# /possibnow-dev-harness:guardrails

View the active safety guardrails protecting your workspace.

## Overview

The `possibnow-dev-harness` plugin installs Tier-1 safety hooks globally in your environment. These hooks intercept dangerous or risky actions before they execute.

## Active Protections

By default, the base hooks (`hooks/hooks.json`) monitor for:
1. **Destructive Commands (validate-bash):** Blocks dangerous commands like `rm -rf`.
2. **Sensitive File Edits (protect-files):** Warns when credentials or critical files are modified.
3. **Format on Write (format-check):** Applies formatting checks when files are written.
4. **Shared Handoff Commit Guard (validate-bash):** Refuses `git commit` while `.agent/HANDOFF.md` is untracked or has unstaged edits, so the shared handoff always ships with the work it describes. It honors `git commit -a` and an inline `git add` that covers the file, and stays silent outside git repos or when the repo has no handoff. Fix: refresh the Current Baton, run `git add .agent/HANDOFF.md`, and retry.

To see the exact rules and prompt changes applied, review your local `.claude/settings.json` or the plugin `hooks/` config files.
