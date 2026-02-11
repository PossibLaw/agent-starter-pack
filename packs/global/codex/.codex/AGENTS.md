# Codex Global Instructions

Global defaults for Codex sessions.

## Scope
- Applies to all Codex sessions unless overridden by project `AGENTS.md`.
- Project-level `AGENTS.md` has higher priority for project-specific behavior.

## Tool Ownership
Codex should treat these as instruction sources by default:
- `~/.codex/AGENTS.md`
- `<project>/AGENTS.md`
- `<project>/.agent/*.md` only when explicitly triggered by task type (planning, review, test, handoff, governance change).

Codex should ignore non-Codex instruction files unless explicitly asked:
- `CLAUDE.md`
- `.claude/*`

## Startup Checklist
1. Resolve working directory.
2. Read `~/.codex/AGENTS.md`.
3. Read `<project>/AGENTS.md` if present.
4. Start requested work immediately. Do not preload `.agent/*.md` files.

## On-Demand State Files
Load only when needed:
- `PLAN.md` for planning requests.
- `REVIEW.md` for review requests.
- `TEST.md` for test/validation requests.
- `HANDOFF.md` for resume or cross-agent baton passing.
- `CONTINUITY.md` only for global workflow/governance changes.

## Standards
- Keep edits minimal and reviewable.
- Use exact file paths and actionable commands.
- Mark unknown facts as `UNCONFIRMED`.
- Return `BLOCKED` with reason and next step when stuck.
- During review tasks, enforce `.agent/REVIEW.md` Security Review Mode and checklist.
- During test/validation tasks, enforce `.agent/TEST.md` security checks for auth, data access, input handling, API, and deployment/runtime changes.
- For code changes, use TDD when feasible: start with a failing test/eval, implement the minimal change, then refactor with tests still passing.
- Never assume eval inputs, acceptance criteria, or expected outputs. Mark gaps as `UNCONFIRMED` and resolve with a targeted user question before execution.
- For new or changed behavior, walk the user through an eval plan in plain language before implementation (at minimum: happy path, edge case, and failure/security case with observable expected results).
- Minimize user friction: infer likely test/eval commands and fixtures from repository signals first; ask the user only targeted follow-ups for unresolved unknowns.

## Safety
- Never expose secrets in output.
- Ask before destructive or irreversible actions.
- Never invent evidence or test results.
