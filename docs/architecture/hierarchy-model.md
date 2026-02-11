# Hierarchy Model

This pack ships two separate instruction hierarchies:

1. Global hierarchy (optional):
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/*.md`
- `~/.codex/AGENTS.md`

2. Project hierarchy (installed into a target repository):
- `<repo>/CLAUDE.md`
- `<repo>/AGENTS.md`
- `<repo>/.agent/*.md`
- `<repo>/.claude/history.md`

## Precedence
- Tool global file applies first.
- Project file overrides global behavior for that repository.
- State files in `.agent/` are on-demand context artifacts.

## Design Rule
- Global files: stable rules that should apply across all projects.
- Project files: repo-specific behavior, commands, and local constraints.
- State files: execution context and handoff, not permanent policy.
