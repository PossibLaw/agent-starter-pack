# File Purpose Map

## Project Pack (`packs/project`)
- `AGENTS.md`: Codex startup and execution contract for a repo.
- `CLAUDE.md`: Claude startup and execution contract for a repo.
- `.agent/PLAN.md`: planning artifact template.
- `.agent/CONTEXT.md`: working context and decisions template.
- `.agent/TASKS.md`: task board with status markers.
- `.agent/REVIEW.md`: review + security checklist.
- `.agent/TEST.md`: validation matrix and security checks.
- `.agent/HANDOFF.md`: baton pass template.
- `.claude/history.md`: cross-session memory log.

## Global Pack (`packs/global`)
- `codex/.codex/AGENTS.md`: Codex user-level global policy.
- `claude/.claude/CLAUDE.md`: Claude user-level global policy.
- `claude/.claude/agents/*.md`: reusable global sub-agents.

## Scripts
- `scripts/install-project.sh`: installs project hierarchy into any repo.
- `scripts/install-global.sh`: optional global hierarchy installer.
- `scripts/verify-pack.sh`: structural and safety checks.
