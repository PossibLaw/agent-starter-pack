# Changelog

## [2026-03-01] - Vendor Recency Verification Rule
**Changed:** Added an explicit vendor rule in `~/.claude/CLAUDE.md`: verify vendor setup/API/security guidance against official vendor docs and cite source date.
**Reason:** Reduce stale guidance risk for vendor integrations and security-sensitive configuration instructions.
**Impact:** Global Claude sessions now have a concrete recency check requirement for vendor-related answers, aligned with Codex policy.
**Decided:** CONFIRMED

## [2026-03-01] - Repo Root State Path Enforcement
**Changed:** Added mandatory repo-root validation and explicit state-file path rules to `~/.claude/CLAUDE.md` for `.agent/PLAN.md`, `.agent/HANDOFF.md`, and `.claude/history.md`.
**Reason:** Prevent state artifacts from being written to temp directories or unresolved paths.
**Impact:** Global Claude sessions now require blocking behavior (`BLOCKED + ask`) for unresolved/ambiguous/temp-root writes and must echo absolute save paths under `${REPO_ROOT}`.
**Decided:** CONFIRMED

## [2026-02-10] - Initial Global Claude Governance
**Changed:** Added `~/.claude/CLAUDE.md` with hierarchy, safety boundaries, context discipline, and verification contract.
**Reason:** Establish a stable global policy layer for all Claude Code sessions.
**Impact:** Project-level and skill-level instructions now inherit explicit conflict resolution and completion rules.
**Decided:** CONFIRMED
