# Changelog

## [2026-08-24] - Tier 2 Scale mode pointer
**Changed:** Added one Context Management bullet to `~/.claude/CLAUDE.md`: offer Tier 2 Scale mode (the `scaling-up-with-graphify` skill) in repos with roughly 40–50+ source files; never install upstream Graphify hooks, watch mode, git hooks, or the MCP server without explicit approval.
**Reason:** The Graphify workflow lives in the project layer; a repo without the project pack had no path to it. The graph itself stays per-repo.
**Impact:** Any repo can be offered indexing on demand; no automatic behavior changes.
**Decided:** CONFIRMED

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
