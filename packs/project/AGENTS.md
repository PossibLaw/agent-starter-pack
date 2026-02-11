# AGENTS.md

Codex project instruction file for <PROJECT_NAME>.

## Startup Contract
1. This file is the only startup instruction. Do not read other files unless triggered.
2. Do the requested task immediately.
3. Load extra files only on trigger:
   - Planning request → `.agent/PLAN.md`
   - Test request → `.agent/TEST.md`
   - Review request → `.agent/REVIEW.md`
   - Handoff, resume, or parallel worktree → `.agent/HANDOFF.md` or `.claude/history.md`
4. If more repo context is needed, read `.claude/history.md` next — not the whole repo.
5. Global continuity stays in `~/.codex/AGENTS.md`. Repo continuity is optional and on-demand.

## Tool Ownership
- Codex reads: `AGENTS.md` (this file), `~/.codex/AGENTS.md` (global).
- Ignore `CLAUDE.md` and `.claude/agents/` unless user explicitly requests cross-agent sync.

## Session Memory
After completing work, append a summary to `.claude/history.md`:
- Date and task title.
- Files changed.
- Key decisions (with status).
- Current state and next steps.

When resuming prior work, read `.claude/history.md` first.

## Roles
- `@orchestrator` — Plan, route, and synthesize outcomes.
- `@research-agent` — Source gathering and fact extraction.
- `@docs-agent` — Documentation edits.
- `@review-agent` — Defect/risk analysis.
- `@test-agent` — Validation execution and receipts.

## Routing Rules
- Architecture/policy tasks → `@orchestrator`.
- Source comparison tasks → `@research-agent`.
- Documentation updates → `@docs-agent`.
- QA/risk review → `@review-agent`.
- Check execution → `@test-agent`.
- If required facts are missing, escalate once with a targeted question.

## Security Review Contract
- For review tasks, apply `.agent/REVIEW.md` Security Review Mode and complete the required security checklist.
- For validation/test tasks, run `.agent/TEST.md` security checks when work touches auth, data access, input handling, API surface, or deployment/runtime settings.

## Boundary Rules
Always do:
- Keep edits within requested scope.
- Cite exact file paths and commands.
- Mark unknowns as `UNCONFIRMED`.

Ask first:
- Destructive actions, schema changes, or remote write operations.
- Scope expansion beyond requested deliverables.

Never do:
- Invent facts or claim completion without validation.
- Remove failing tests to force passing results.
- Expose secrets.
- Modify Claude-specific files (`CLAUDE.md`, `.claude/*`) unless user explicitly asks.
- Read instruction files not triggered by the current task.

## Git Workflow Contract
- Use focused branches and atomic commits.
- Attach validation evidence to PRs/handoffs.
- Never commit credentials.

## Local Norms
- Persist repeated user corrections here so they survive across sessions.
- Do not duplicate higher-layer policy from `~/.codex/AGENTS.md`.
