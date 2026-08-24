---
name: running-novice-safe-git-cycle
description: Use when work is ready to ship and the developer needs a novice-safe git workflow; review scope, run checks, refresh the shared handoff plus local working state, and move through commit, push, and PR steps without leaking secrets or local state files.
metadata:
  version: 1.1.0
---

# Running Novice-Safe Git Cycle

## Inputs
- changed files
- relevant validation commands and receipts
- current handoff status

## Steps
1. Inspect `git status --short` and `git diff --stat` to confirm scope.
2. Remove accidental files, debug leftovers, secrets, unrelated changes, and local `.agent/*` working state other than `.agent/HANDOFF.md` from the candidate commit.
3. Run the smallest relevant checks first, then the full required checks for the change.
4. Refresh canonical newest-first state in `.agent/PLAN.md` and `.agent/HANDOFF.md` (current baton + timeline), review the handoff for sensitive data, then stage it explicitly with `git add .agent/HANDOFF.md` — every commit must carry the current handoff (in Claude Code the guardrail blocks a commit that leaves it untracked or unstaged).
5. Leave git-cycle status explicit in the handoff: reviewing, ready to commit, committed, pushed, or PR open.
6. Create a focused commit with a descriptive message.
7. Push the branch and open or update the PR when a remote workflow exists.

## Outputs
- clean staged scope
- validation evidence captured
- shared handoff refreshed and included; local working state excluded
- next git step obvious to a novice developer

## Common Mistakes
- omitting a relevant `.agent/HANDOFF.md` update and leaving collaborators with stale continuity
- running `git commit` before `git add .agent/HANDOFF.md` (blocked by the Claude Code guardrail; a contract violation everywhere else)
- committing local `.agent/*` working state other than `.agent/HANDOFF.md`
- committing secrets, raw private client data, or machine-specific paths in the shared handoff
- creating sidecar continuity files instead of updating the canonical files
- skipping the checkpoint before a commit
- mixing unrelated changes into one commit
- claiming checks passed without receipts
