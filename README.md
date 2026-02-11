# PossibLaw Agent Starter Pack

Install a complete Claude + Codex instruction hierarchy into any repository without writing files from scratch.

This repository includes:
- Project-level instruction files (`AGENTS.md`, `CLAUDE.md`, `.agent/*`, `.claude/history.md`).
- Optional global instruction files (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.claude/agents/*.md`).
- Full reference/source docs used to design this workflow.

## Quick Start (Project Files)

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd PossibLaw-Agent-Starter-Pack
./scripts/install-project.sh /path/to/your/repo
```

If you are already inside the target repo, call the installer by path:

```bash
/path/to/agent-starter-pack/scripts/install-project.sh .
```

`install-project.sh` now auto-detects likely commands from repo signals (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, lockfiles). Use overrides only when you want explicit values:

```bash
./scripts/install-project.sh /path/to/your/repo \
  --name "your-project" \
  --owner "your-team" \
  --primary "pnpm dev" \
  --test "pnpm test" \
  --lint "pnpm lint" \
  --typecheck "pnpm typecheck" \
  --build "pnpm build"
```

## Optional Global Setup

Install Codex and Claude global files:

```bash
./scripts/install-global.sh --codex --claude
```

Install only one tool:

```bash
./scripts/install-global.sh --codex
./scripts/install-global.sh --claude
```

## What Gets Added

### Project-level target repo
- `AGENTS.md`
- `CLAUDE.md`
- `.claude/history.md`
- `.agent/PLAN.md`
- `.agent/CONTEXT.md`
- `.agent/TASKS.md`
- `.agent/REVIEW.md`
- `.agent/TEST.md`
- `.agent/HANDOFF.md`

### Global-level home folder (optional)
- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/*.md`

## Safety and Rollback
- Existing destination files are backed up before overwrite.
- Backup format: `<filename>.bak.<timestamp>`.
- Installers only copy curated files from `packs/`.
- Runtime files, auth files, logs, and caches are never installed.

## Verify This Pack

```bash
./scripts/verify-pack.sh
```

## Repository Layout

```text
packs/
  project/                 # Repo-level files
  global/claude/           # ~/.claude curated files
  global/codex/            # ~/.codex curated files
scripts/
  install-project.sh
  install-global.sh
  verify-pack.sh
docs/
  references/              # Full source docs
  architecture/
  onboarding/
```

## Source Lineage
- `docs/references/claude-md-agents-md-reference-guide.md`
- `docs/references/agent-instructions-summary.md`
- `docs/references/claude-agents-README.md`

## Notes
- Launch support is macOS + Linux.
- If you need Windows support, use manual copy steps in `docs/onboarding/non-technical-quickstart.md`.
