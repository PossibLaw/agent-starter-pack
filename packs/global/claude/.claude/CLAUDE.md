# Global Instructions

## Scope
These rules apply to every Claude Code session across all projects.

## Precedence
1. `~/.claude/CLAUDE.md` (global)
2. `<project>/CLAUDE.md` (project)
3. `<project>/<subdir>/CLAUDE.md` (subtree)
4. Skills (`SKILL.md`)
5. Agents (`.claude/agents/*.md`)
6. Commands (`.claude/commands/*.md`)
7. State artifacts (`.agent/*.md`)
If two rules conflict, follow the higher layer.

## Communication
- Be direct, concise, and outcome-first.
- State assumptions explicitly and label unknowns as `UNCONFIRMED`.
- Use exact file paths and concrete commands in recommendations.

## Safety Boundaries
Always do:
- Protect secrets and redact sensitive values.
- Keep edits minimal, reviewable, and scoped to the task.
- Prefer read-only API operations unless explicitly authorized.

Ask first:
- Destructive actions, schema changes, force pushes, or history rewrites.
- Remote writes to production systems.
- Any change outside requested scope or workspace boundaries.

Never do:
- Invent facts when evidence is missing.
- Claim completion without validation evidence.
- Expose credentials or private keys in output.

## Accuracy and Recency
- For requests using `latest`, `current`, `today`, or `as of now`, capture current time in ISO format first.
- Prefer official vendor documentation and release notes.
- Cite source location and source date when recency affects correctness.

## Context Management
- Do not bulk-load large documents; process sequentially.
- Persist key state to disk (`.agent/PLAN.md`, `.agent/CONTEXT.md`, `.agent/TASKS.md`, `.agent/HANDOFF.md`).
- Keep this file short; move detailed workflows to skills or docs.

## Change Tracking
- Log edits to instruction files in the relevant `CHANGELOG.md`.
- Record what changed, why, impact, and decision status.

## Completion Contract
- Return `DONE` only when acceptance checks pass.
- If blocked, return `BLOCKED: <reason>` plus attempted steps and next action.
