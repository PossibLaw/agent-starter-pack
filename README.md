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
- `.agent/HANDOFF.md`: Session baton-pass template for local continuity between agent sessions.
- `.agent/LEARNINGS.md`: Optional learning log (default off) for capturing reusable observations and proposed skill/plugin/instruction improvements.
- `.claude/history.md`: Ongoing local session memory log for timeline, decisions, and next steps.

### Optional global files
- `~/.codex/AGENTS.md`: User-level Codex defaults that apply across repositories.
- `~/.claude/CLAUDE.md`: User-level Claude defaults that apply across repositories.
- `~/.claude/agents/*.md`: Reusable specialist agents available to Claude sessions.

This repository includes:
- Project-level instruction files (`AGENTS.md`, `CLAUDE.md`, `.agent/*`, `.claude/history.md`).
- Optional global instruction files (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.claude/agents/*.md`).
- Full reference/source docs used to design this workflow.

## Quick Start (Project Files)

### macOS + Linux (run from inside your target repo)

```bash
curl -fsSL https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.sh | bash -s -- .
```

If you prefer not to execute a remote script directly:

```bash
git clone --depth 1 https://github.com/PossibLaw/agent-starter-pack.git /tmp/agent-starter-pack
/tmp/agent-starter-pack/scripts/install-project.sh .
rm -rf /tmp/agent-starter-pack
```

### Windows (PowerShell 7+, run from inside your target repo)

```powershell
$bootstrap = Join-Path $env:TEMP "bootstrap-project.ps1"
irm https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.ps1 -OutFile $bootstrap
pwsh -File $bootstrap .
Remove-Item $bootstrap -Force
```

### Manual install from a local starter-pack clone

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd agent-starter-pack
./scripts/install-project.sh ~/code/my-app
```

```powershell
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd agent-starter-pack
pwsh -File .\scripts\install-project.ps1 C:\code\my-app
```

Tip: `git clone` uses the repository name (`agent-starter-pack`) as the folder unless you pass a custom destination:

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git PossibLaw-Agent-Starter-Pack
```

The project installer auto-detects likely commands from repo signals (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, lockfiles). Use overrides only when you want explicit values:

```bash
./scripts/install-project.sh ~/code/my-app \
  --name "your-project" \
  --owner "your-team" \
  --primary "pnpm dev" \
  --test "pnpm test" \
  --lint "pnpm lint" \
  --typecheck "pnpm typecheck" \
  --build "pnpm build"
```

```powershell
pwsh -File .\scripts\install-project.ps1 C:\code\my-app `
  --name "your-project" `
  --owner "your-team" `
  --primary "pnpm dev" `
  --test "pnpm test" `
  --lint "pnpm lint" `
  --typecheck "pnpm typecheck" `
  --build "pnpm build"
```

The project installer also adds local-continuity ignore rules to the target repo `.gitignore` so `.claude/history.md` and `.agent/*.md` state files stay local by default.

### Pick the Right Mode

- Brand new repo: run quick start as-is (no flags). This creates all starter-pack files.
- Existing repo, keep progress/history/handoff: use `--preserve-progress`.
- Existing repo, intentionally reset progress/history/handoff to fresh templates: run without `--preserve-progress`.

Intentional full reset example (run from inside target repo):

```bash
curl -fsSL https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.sh | bash -s -- .
```

```powershell
$bootstrap = Join-Path $env:TEMP "bootstrap-project.ps1"
irm https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.ps1 -OutFile $bootstrap
pwsh -File $bootstrap .
Remove-Item $bootstrap -Force
```

### Update an Existing Repo Without Overwriting Progress Files

Use `--preserve-progress` when a repo already has starter-pack files and you want to keep existing progress artifacts (for example `.claude/history.md`, `.agent/HANDOFF.md`, `.agent/TASKS.md`).

```bash
curl -fsSL https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.sh | bash -s -- . --preserve-progress
```

```powershell
$bootstrap = Join-Path $env:TEMP "bootstrap-project.ps1"
irm https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.ps1 -OutFile $bootstrap
pwsh -File $bootstrap . --preserve-progress
Remove-Item $bootstrap -Force
```

## Optional Global Setup

Install Codex and Claude global files:

```bash
./scripts/install-global.sh --codex --claude
```

```powershell
pwsh -File .\scripts\install-global.ps1 --codex --claude
```

Install only one tool:

```bash
./scripts/install-global.sh --codex
./scripts/install-global.sh --claude
```

```powershell
pwsh -File .\scripts\install-global.ps1 --codex
pwsh -File .\scripts\install-global.ps1 --claude
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
- `.gitignore` updates for local continuity files (`.claude/history.md` and `.agent/*.md`)

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

```powershell
pwsh -File .\scripts\verify-pack.ps1
```

## Learning Mode Helper

Set learning mode in a repo's `.agent/PLAN.md` without manual edits:

```bash
# from inside target repo
/path/to/agent-starter-pack/scripts/set-learning-mode.sh CAPTURE

# explicit target repo path
/path/to/agent-starter-pack/scripts/set-learning-mode.sh /path/to/your/repo OFF
```

```powershell
# from inside target repo
pwsh -File C:\path\to\agent-starter-pack\scripts\set-learning-mode.ps1 CAPTURE

# explicit target repo path
pwsh -File C:\path\to\agent-starter-pack\scripts\set-learning-mode.ps1 C:\path\to\your\repo OFF
```

## Repository Layout

```text
packs/
  project/                 # Repo-level files
  global/claude/           # ~/.claude curated files
  global/codex/            # ~/.codex curated files
scripts/
  bootstrap-project.sh
  install-project.sh
  install-global.sh
  verify-pack.sh
  set-learning-mode.sh
  bootstrap-project.ps1
  install-project.ps1
  install-global.ps1
  verify-pack.ps1
  set-learning-mode.ps1
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
- Launch support is macOS, Linux, and Windows (PowerShell 7+).
