---
contract_version: 1
artifact_type: handoff
status: IN_PROGRESS
depends_on:
  - .agent/PLAN.md
produces:
  - next_actions
  - open_questions
  - decision_summary
  - session_timeline
feeds_into:
  - .agent/WIKI.md
memory:
  include_in_memory: true
  tags: [handoff]
---

# HANDOFF

Shared, version-controlled continuity file. Current baton on top; dated Session Timeline below the STOP marker. No separate history file.

## Current Baton (Read First)

## Status
- Current phase: shared HANDOFF policy and README command-copy cleanup complete; ready for commit
- Owner: repository maintainers
- Timestamp (ISO): 2026-08-04
- Overall status: `READY_FOR_COMMIT`
- Checkpoint reason: `task-end`
- Tier: `1 (Starter)`
- Scale mode: `OFF`

## What Was Completed
- Item: made `.agent/HANDOFF.md` the only shared, trackable agent-state document while keeping PLAN/TEST/REVIEW/WIKI/LEARNINGS local.
  - Evidence: installer migration, fresh-install, and broader-custom-rule fixtures pass in `./scripts/verify-pack.sh`.
- Item: split README command sequences into one-command code blocks.
  - Evidence: every executable README block now contains one shell/slash command; multi-line installer overrides remain one continued command.
- Item: aligned project instructions, workflow contract, onboarding, init command, glossary, changelog, and git-cycle skill with the shared-handoff policy.
  - Evidence: pack verification and skill validation pass.

## Decisions
- Decision: `.agent/HANDOFF.md` is shared and version-controlled because it carries the current baton and newest-first history. Status: `CONFIRMED`
- Decision: all other `.agent/*.md` working-state documents remain local and ignored by default. Status: `CONFIRMED`
- Decision: broader custom ignore rules are preserved; the installer warns when one still hides HANDOFF instead of silently changing unrelated repository policy. Status: `CONFIRMED`

## Open Questions
- None for this change.

## Next Actions
1. Commit the policy/docs change together with the now-trackable `.agent/HANDOFF.md`.
2. Push/open a PR only when the repository owner requests the remote step.

## Sprint / Git Cycle
- Sprint label: shared handoff continuity
- Sprint status: `COMPLETE`
- Git cycle status: `READY_TO_COMMIT`
- Branch: `codex/share-handoff-history`
- Recommended next git step: review and create one focused commit

## Learning / Memory
- Learning mode: `OFF`
- Learnings updated: `N/A`

## Do-Not-Reread
- Old reference docs under `docs/references/` unless a sourcing question arises.

## Contract Links (Required)
- Eval IDs covered: legacy migration, fresh install, broader custom ignore rule, README one-command blocks
- Test receipts referenced: `./scripts/verify-pack.sh` (PASS); shell syntax (PASS); skill validation (PASS); guardrail pytest `UNCONFIRMED` because pytest is unavailable in the active and bundled Python runtimes
- Review findings referenced: none open

STOP: normal resume context ends here; older entries below are archive.

## Session Timeline (Newest First)

### 2026-08-04 — Shared HANDOFF continuity + copyable README commands
- Checkpoint reason: task-end
- Files changed: ignore policy, installer and verification fixture, project instructions/contracts, init/onboarding/glossary/changelog, README, git-cycle skill, and the root HANDOFF now exposed for tracking.
- Decisions: only `.agent/HANDOFF.md` is shared; other `.agent/*.md` working state stays local; custom broader ignore rules produce a warning.
- Current state: implementation complete and `./scripts/verify-pack.sh` passes; skill validation passes; pytest is unavailable in the installed Python runtimes.
- Next steps: review and commit, then push/PR only if requested.
- Git cycle: ready to commit.
- Learnings: not enabled.

### 2026-06-29 — v3.0.0 first-principles refresh (two-tier progressive harness)
- Checkpoint reason: handoff
- Files changed: broad — merged HANDOFF+history; folded CONTEXT/TASKS into PLAN; added Tier-2 scale command/skill, simplicity-ladder skill, token-management.md; refreshed graphify.md; removed MemPalace + all PowerShell + 3 unused agents + persist-state sidecar; rewrote CLAUDE/AGENTS/contracts/verify-pack/installer.
- Decisions: see Current Baton above (all CONFIRMED).
- Current state: committed `fa8f6cf` on `refresh/v3-progressive-harness`; verify-pack + 107 tests pass.
- Next steps: adopt/size feature, README, push/PR/merge.
- Git cycle: committed.
- Learnings: not enabled.

### 2026-04-21 — Continuity checkpoint workflow + novice-safe git cycle
- Checkpoint reason: handoff
- Decisions: added explicit continuity checkpoints + helper scripts; novice-safe git cycle skill/checklist. (MemPalace helper-contract approach from this date was later removed in the v3 refresh.)
- Current state at the time: pack changes implemented and validated; local root continuity files created for baton pass.
- Note: superseded by the 2026-06-29 refresh.

### 2026-04-09 — Canonical role registry + plugin ownership split
- Files changed: `docs/roles/*`, `AGENTS.md`, `CLAUDE.md`, `contracts.md`, installers, verify-pack, CHANGELOG.
- Key decisions: canonical role contracts live in `packs/project/docs/roles/*.md`; Codex/Claude routing files are thin wrappers; Plugins repo handles runtime/distribution, not the canonical contract.
- Validation: `./scripts/verify-pack.sh` PASS; marketplace validation PASS.
- Note: the `task-planner`/`test-agent` compatibility wrappers kept then were removed in the v3 refresh.
