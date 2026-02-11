# CLAUDE.md

<PROJECT_NAME> — replace this line with a 2-line project description.

## Startup Contract
1. This file is the only startup instruction. Do not read other files unless triggered.
2. Do the requested task immediately.
3. Load extra files only on trigger:
   - Planning request → `.agent/PLAN.md`
   - Test request → `.agent/TEST.md`
   - Review request → `.agent/REVIEW.md`
   - Handoff, resume, or parallel worktree → `.agent/HANDOFF.md` or `.claude/history.md`
4. If more repo context is needed, read `.claude/history.md` next — not the whole repo.
5. Global continuity stays in `~/.claude/CLAUDE.md`. Repo continuity is optional and on-demand.

## Session Memory
After completing work, append a summary to `.claude/history.md`:
- Date and task title.
- Files changed.
- Key decisions (with status).
- Current state and next steps.

When resuming prior work, read `.claude/history.md` first.

## Commands
`<PRIMARY_COMMAND>` - Primary local workflow command.
`<TEST_COMMAND>` - Run tests.
`<LINT_COMMAND>` - Run linting.
`<TYPECHECK_COMMAND>` - Run type checks.
`<BUILD_COMMAND>` - Build or package the project.

Run `<LINT_COMMAND> && <TYPECHECK_COMMAND> && <TEST_COMMAND>` before handoff.

## Stack
- Runtime:
- Framework:
- Data layer:
- Testing:
- Tooling:

## Code Map
- Entry point:
- Config files:
- API layer:
- Domain logic:
- Data/storage:
- Tests:

## Agent Routing
- Task planning or phased implementation → `@task-planner`
- Source extraction or fact gathering → `@research-agent`
- Markdown drafting or doc updates → `@docs-agent`
- Quality or risk review → `@review-agent`
- Test suite generation → `@test-generator`

## Boundary Rules
Always do:
- Keep edits scoped to requested files.
- Reference exact paths and commands.
- Mark unknowns as `UNCONFIRMED`.

Ask first:
- Destructive operations or schema-changing edits.
- Large refactors outside the stated objective.

Never do:
- Invent evidence or claim completion without validation.
- Remove failing tests to force a pass.
- Expose secrets.
- Read instruction files not triggered by the current task.

## Local Norms
- Persist repeated user corrections here so they survive across sessions.
- Do not duplicate higher-layer policy from `~/.claude/CLAUDE.md`.
