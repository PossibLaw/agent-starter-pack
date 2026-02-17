# PossibLaw Agent Starter Pack

Install a complete Claude + Codex instruction hierarchy into any repository without writing files from scratch.

Built to make AI-assisted software delivery consistent and reliable, this pack standardizes planning, testing, review, and handoff workflows for both Codex and Claude.
It was created by reviewing and distilling hundreds of pages of guides and best-practice references (captured under `docs/references/`) into practical, reusable templates.

## What Each File Does

### Project-level files
- `AGENTS.md`: Codex operating contract for the repo; defines scope, execution standards, and routing behavior.
- `CLAUDE.md`: Claude operating contract for the repo; mirrors delivery and safety expectations for Claude workflows.
- `.agent/PLAN.md`: Working plan template to define objective, milestones, risks, and acceptance criteria.
- `.agent/CONTEXT.md`: Active context capture for assumptions, constraints, and key facts discovered during execution.
- `.agent/TASKS.md`: Action checklist to track in-progress, done, blocked, and unconfirmed work items.
- `.agent/REVIEW.md`: Structured review rubric focused on correctness, regressions, and security findings.
- `.agent/TEST.md`: Validation contract with TDD/eval evidence requirements and security test checklist.
- `.agent/HANDOFF.md`: Session baton-pass template so another agent can resume work with minimal loss of context.
- `.agent/LEARNINGS.md`: Optional learning log (default off) for capturing reusable observations and proposed skill/plugin/instruction improvements.
- `.claude/history.md`: Ongoing session memory log for timeline, decisions, and next steps.

### Optional global files
- `~/.codex/AGENTS.md`: User-level Codex defaults that apply across repositories.
- `~/.claude/CLAUDE.md`: User-level Claude defaults that apply across repositories.
- `~/.claude/agents/*.md`: Reusable specialist agents available to Claude sessions.

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
- `.agent/LEARNINGS.md`

`Learning Mode` defaults to `OFF`. Turn it on per task by setting `Learning Mode: CAPTURE` or `Learning Mode: APPLY` in `.agent/PLAN.md` (or by explicit prompt instruction).

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

## Learning Mode Helper

Set learning mode in a repo's `.agent/PLAN.md` without manual edits:

```bash
# from inside target repo
/path/to/agent-starter-pack/scripts/set-learning-mode.sh CAPTURE

# explicit target repo path
/path/to/agent-starter-pack/scripts/set-learning-mode.sh /path/to/your/repo OFF
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
  set-learning-mode.sh
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
