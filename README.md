# PossibLaw Agent Starter Pack

Install a complete Claude + Codex instruction hierarchy into any repository without writing files from scratch.

Built to make AI-assisted software delivery consistent and reliable, this pack standardizes planning, testing, review, and handoff workflows for both Codex and Claude.
It was created by reviewing and distilling hundreds of pages of guides and best-practice references (captured under `docs/references/`) into practical, reusable templates.

## Canonical Role Model

The starter pack is the canonical home for host-agnostic delivery roles.

- Shared role contracts live in `packs/project/docs/roles/*.md`.
- Codex routing lives in `packs/project/AGENTS.md`.
- Claude routing lives in `packs/project/CLAUDE.md` and `packs/global/claude/.claude/agents/*.md`.
- Plugin packages and runtime adapters belong in the separate Plugins repository.

## What Each File Does

### Project-level files
- `AGENTS.md`: Codex operating contract for the repo; defines scope, execution standards, and routing behavior.
- `CLAUDE.md`: Claude operating contract for the repo; mirrors delivery and safety expectations for Claude workflows.
- `docs/vendor/README.md`: Vendor-doc contract; defines how agents should use local vendor references over model memory.
- `docs/vendor/supabase.md`: Initial vendor reference guide (Supabase) with key usage, env patterns, and security reminders.
- `docs/roles/README.md`: Canonical host-agnostic role registry for planning, review, validation, and handoff work.
- `docs/roles/*.md`: Shared role contracts that Claude and Codex wrappers should both follow.
- `docs/workflows/evals.md`: Evals-driven development guide to define “done” and iterate safely (with extra guidance for LLM features).
- `docs/workflows/contracts.md`: Typed workflow contract for `PLAN -> TEST -> REVIEW -> HANDOFF`, plus optional memory and stage-skill integration rules.
- `docs/workflows/wiki.md`: Optional wiki-mode workflow for persistent codebase context (Obsidian-friendly) with trust-order and verification rules.
- `.agent/PLAN.md`: Working plan template to define objective, milestones, risks, and acceptance criteria.
- `.agent/CONTEXT.md`: Active context capture for assumptions, constraints, and key facts discovered during execution.
- `.agent/TASKS.md`: Action checklist to track in-progress, done, blocked, and unconfirmed work items.
- `.agent/REVIEW.md`: Structured review rubric focused on correctness, regressions, and security findings.
- `.agent/TEST.md`: Validation contract with TDD/eval evidence requirements and security test checklist.
- `.agent/HANDOFF.md`: Session baton-pass template for local continuity between agent sessions.
- `.agent/WIKI.md`: Optional wiki-mode config with Obsidian vault path and wiki sync rules.
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
- Architecture decision guides, including `docs/architecture/memory-and-indexing-guide.md`.

## Quick Start (Project Files)

### Pick the Right Mode

- Brand new repo: run quick start as-is (no `--preserve-progress`). This creates all starter-pack files.
- Existing repo, keep progress/history/handoff: add `--preserve-progress`.
- Existing repo, intentionally reset progress/history/handoff to fresh templates: run without `--preserve-progress`.

If you run the installer in a brand-new/empty repo (no detectable stack files yet), you may see a warning that commands are `UNCONFIRMED`. This is expected—either initialize the project and re-run, pass explicit `--primary/--test/--lint/--typecheck/--build` overrides, or edit `.agent/TEST.md` and `CLAUDE.md`.

### macOS + Linux (run from inside your target repo)

Brand new repo:

```bash
curl -fsSL https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.sh | bash -s -- .
```

Existing repo (preserve progress files):

```bash
curl -fsSL https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.sh | bash -s -- . --preserve-progress
```

If you prefer not to execute a remote script directly:

```bash
git clone --depth 1 https://github.com/PossibLaw/agent-starter-pack.git /tmp/agent-starter-pack
/tmp/agent-starter-pack/scripts/install-project.sh .
rm -rf /tmp/agent-starter-pack
```

### Windows (PowerShell 7+, run from inside your target repo)

Brand new repo:

```powershell
$bootstrap = Join-Path $env:TEMP "bootstrap-project.ps1"
irm https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.ps1 -OutFile $bootstrap
pwsh -File $bootstrap .
Remove-Item $bootstrap -Force
```

Existing repo (preserve progress files):

```powershell
$bootstrap = Join-Path $env:TEMP "bootstrap-project.ps1"
irm https://raw.githubusercontent.com/PossibLaw/agent-starter-pack/main/scripts/bootstrap-project.ps1 -OutFile $bootstrap
pwsh -File $bootstrap . --preserve-progress
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
- `.agent/WIKI.md`
- `.agent/LEARNINGS.md`
- `docs/vendor/README.md`
- `docs/vendor/supabase.md`
- `docs/roles/README.md`
- `docs/roles/product-strategist.md`
- `docs/roles/engineering-planner.md`
- `docs/roles/reviewer.md`
- `docs/roles/security-reviewer.md`
- `docs/roles/qa-validator.md`
- `docs/roles/docs-releaser.md`
- `docs/workflows/evals.md`
- `docs/workflows/contracts.md`
- `docs/workflows/wiki.md`
- `.gitignore` updates for local continuity files (`.claude/history.md` and `.agent/*.md`)

`Learning Mode` defaults to `OFF`. Turn it on per task by setting `Learning Mode: CAPTURE` or `Learning Mode: APPLY` in `.agent/PLAN.md` (or by explicit prompt instruction).

### Global-level home folder (optional)
- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/*.md`

## Vendor Docs Workflow
- Keep project-curated vendor integration guidance in `docs/vendor/<vendor>.md`.
- Include `Last verified: YYYY-MM-DD` and official source links in each vendor file.
- Agents should read `docs/vendor/` first for vendor/API/security setup work, then verify against current official docs when recency matters.

## Contract Pipeline and Optional Integrations
- `docs/workflows/contracts.md` defines the typed artifact header and cross-artifact linkage rules.
- Required stage order: `PLAN -> TEST -> REVIEW -> HANDOFF`.
- Optional MemPalace integration is documented in raw retrieval mode; local files remain the source of truth.
- Optional stage-skill integration (gstack-inspired) is additive and must keep file-based fallback behavior.

## Memory
- `docs/architecture/memory-and-indexing-guide.md` explains which memory/indexing layer owns which facts and when to enable optional backends.
- Source code, tests, runtime behavior, and active state artifacts remain the source of truth.
- `.agent/HANDOFF.md` carries the current baton pass; `.claude/history.md` carries the append-only session timeline.
- `.agent/LEARNINGS.md` is default-off and should capture reusable process observations only when `Learning Mode` is `CAPTURE` or `APPLY`.
- MemPalace is an optional retrieval index over completed local artifacts, not a second place to author decisions.
- Wiki mode and Graphify are orientation/indexing layers; generated claims stay advisory until verified against source.

Examples:
- Local artifact: a handoff records that matter records are created only after `conflict_check.status = approved`, why draft matters for rejected intakes were rejected, what tests proved it, and what remains open.
- MemPalace: after the handoff is complete, ingest the raw handoff/test/review/history chunks with metadata such as repo, artifact type, source path, timestamp, task title, tags, and commit SHA. A later query for "automated reminders for eligible intakes" can retrieve the old conflict-check decision even if the exact words differ.
- Manual wiki: use curated pages for stable codebase maps, domain glossary, architecture notes, and cross-links that humans may want to edit.
- Graphify: use generated `graphify-out/GRAPH_REPORT.md` and focused graph queries for first-pass orientation on larger repos, then verify the result in source before implementation.
- Non-developer path: ask the agent to "index this codebase with Graphify." The project contract tells the agent to configure `.agent/WIKI.md`, create safe ignore rules, install Graphify only with approval if missing, run the graph build, and report where the output lives.

## Optional Wiki Mode
- `docs/workflows/wiki.md` defines how to use a persistent wiki for faster startup context.
- Wiki mode is for orientation and synthesis, not authority; source code and tests remain authoritative.
- Supports both in-repo wiki files and external Obsidian vaults on local disk.
- Wiki backend defaults to `manual`; `graphify` is an optional generated graph/wiki backend.
- Graphify output such as `graphify-out/GRAPH_REPORT.md` and `graphify-out/graph.json` is advisory until verified against source.
- Do not install Graphify always-on assistant hooks, git hooks, or watch mode without explicit user approval.
- To enable it in a repo, set `Enabled: ON` and update `Vault root (absolute)` in `.agent/WIKI.md`.
- After vault setup, the wiki root is generated with `{vault_root}/codebases/{repo_name}` and reused for handoff/history sync.

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
    docs/roles/            # Canonical host-agnostic role contracts
    docs/vendor/           # Local vendor integration references
    docs/workflows/        # Evals and contract pipeline guidance
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
