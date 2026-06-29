# PossibLaw Agent Starter Pack

Install a complete Claude + Codex instruction hierarchy into any repository without writing files from scratch.

Built to make AI-assisted software delivery consistent and reliable, this pack standardizes planning, testing, review, and handoff workflows for both Codex and Claude.
It was created by reviewing and distilling hundreds of pages of guides and best-practice references (captured under `docs/references/`) into practical, reusable templates.

## Quick install (Claude Code)

```
/plugin marketplace add PossibLaw/PossibLaw-Plugins
/plugin install possiblaw-starter@possiblaw-plugins
```

This installs the plugin: runtime guardrails (destructive-command blocker, sensitive-file protection, format-on-write), host-agnostic agents, and repo-local skills — all available globally to every Claude Code session.

Then, **inside any project repo where you want the state-artifact pipeline + governance files**, run:

```
/possiblaw-starter:init
```

This scaffolds `AGENTS.md`, `CLAUDE.md`, `.agent/{PLAN,TEST,REVIEW,HANDOFF,...}.md`, `docs/roles/`, `docs/workflows/`, `docs/glossary.md`, and `.claude/skills/` into the current working directory. It auto-detects your stack (Node/Python/Go/Rust) and pre-fills test/lint/build commands. Pass `--preserve-progress` to skip overwriting existing state files; pass `--dry-run` to preview.

Codex users skip the plugin entirely and use the bootstrap installer below — Codex parity is preserved because `packs/global/codex/` and `packs/project/AGENTS.md` ship unchanged.

> **Tier 2 hooks (off by default):** the optional `hooks/tier2-hooks.json` (validate-task, validate-subagent, sanitize-input, git-status SessionStart) is shipped but **not active by default**. To enable them, merge the entries from `hooks/tier2-hooks.json` into your `.claude/settings.json` (or symlink the file into the plugin's hooks loader). The base `hooks/hooks.json` (destructive-command blocker, sensitive-file protection, format-on-write) is on by default once the plugin is installed.

## Two Tiers (How This Pack Grows With You)

The harness is built for non-developer legal users and starts simple. It has two tiers, and it grows with your codebase instead of overwhelming you up front.

- **Tier 1 — Starter (default):** the everyday workflow most projects ever need — `PLAN → TEST → REVIEW → HANDOFF`, a single continuity file, runtime guardrails, the **simplicity ladder** (prefer the simplest thing that works: reuse before writing new code), and always-on token discipline.
- **Tier 2 — Scale (opt-in, gated as the codebase grows):** indexed retrieval with Graphify, wiki orientation, and deeper review. When a repo gets large the harness suggests `/possiblaw-starter:scale`; you opt in. Tier 2 never removes Tier 1 rules — it only adds to them.

Learnings are **validation-gated**: a lesson is promoted into `.agent/LEARNINGS.md` only if it recurred at least twice or you explicitly confirmed it, so the learnings file stays small and trustworthy.

## Canonical Role Model

The starter pack is the canonical home for host-agnostic delivery roles.

- Shared role contracts live in `packs/project/docs/roles/*.md`.
- Codex routing lives in `packs/project/AGENTS.md`.
- Claude routing lives in `packs/project/CLAUDE.md` and the top-level `agents/*.md` (promoted from `packs/global/claude/.claude/agents/` in v2.0.0).
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
- `docs/workflows/contracts.md`: Typed workflow contract for `PLAN -> TEST -> REVIEW -> HANDOFF`, plus continuity checkpoints and optional memory/stage-skill integration rules.
- `docs/workflows/wiki.md`: Optional wiki-mode workflow for persistent codebase context (Obsidian-friendly) with trust-order and verification rules.
- `.agent/PLAN.md`: Working plan template — objective, assumptions, milestones, risks, and acceptance criteria (now also absorbs the former CONTEXT and TASKS checklists).
- `.agent/REVIEW.md`: Structured review rubric focused on correctness, regressions, and security findings.
- `.agent/TEST.md`: Validation contract with TDD/eval evidence requirements and security test checklist.
- `.agent/HANDOFF.md`: Single continuity file — current baton pass on top, a newest-first dated Session Timeline below a STOP marker.
- `.agent/WIKI.md`: Optional wiki-mode config with Obsidian vault path and wiki sync rules (Tier 2).
- `.agent/LEARNINGS.md`: Optional, validation-gated learning log (default off) for reusable observations and proposed skill/plugin/instruction improvements.
- `.agent/integrations/*`: Local advisory checkpoint helper (`run-checkpoint.sh`) that prints the PLAN/HANDOFF updates to make.
- `docs/workflows/token-management.md`: Token/context budgeting guide so the harness stays fast and cheap.
- `.claude/skills/*/SKILL.md`: Repo-local workflow skills for repeated procedures (sprint closeout, novice-safe git cycle, the simplicity ladder, and scaling up with Graphify).

### Optional global files
- `~/.codex/AGENTS.md`: User-level Codex defaults that apply across repositories.
- `~/.claude/CLAUDE.md`: User-level Claude defaults that apply across repositories.
- `~/.claude/agents/*.md`: Reusable specialist agents available to Claude sessions.

This repository includes:
- Project-level instruction files (`AGENTS.md`, `CLAUDE.md`, `.agent/*`).
- Repo-local workflow skills under `.claude/skills/`.
- Optional global instruction files (`~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.claude/agents/*.md`).
- Full reference/source docs used to design this workflow.
- Architecture decision guides, including `docs/architecture/memory-and-indexing-guide.md`.

## Quick Start (Project Files)

### Pick the Right Mode

- Brand new repo: run quick start as-is (no `--preserve-progress`). This creates all starter-pack files.
- Existing repo, keep progress (PLAN/HANDOFF continuity): add `--preserve-progress`.
- Existing repo, intentionally reset progress (PLAN/HANDOFF) to fresh templates: run without `--preserve-progress`.

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

### Manual install from a local starter-pack clone

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd agent-starter-pack
./scripts/install-project.sh ~/code/my-app
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

The project installer also adds local-continuity ignore rules to the target repo `.gitignore` so `.agent/*.md` state files (including the single `.agent/HANDOFF.md` continuity file) stay local by default.

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
- `.agent/PLAN.md`
- `.agent/REVIEW.md`
- `.agent/TEST.md`
- `.agent/HANDOFF.md`
- `.agent/WIKI.md`
- `.agent/LEARNINGS.md`
- `.agent/integrations/README.md`
- `.agent/integrations/run-checkpoint.sh`
- `.claude/skills/closing-sprint-and-syncing-state/SKILL.md`
- `.claude/skills/running-novice-safe-git-cycle/SKILL.md`
- `.claude/skills/applying-simplicity-ladder/SKILL.md`
- `.claude/skills/scaling-up-with-graphify/SKILL.md`
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
- `docs/workflows/graphify.md`
- `docs/workflows/token-management.md`
- `docs/glossary.md`
- `.gitignore` updates for local continuity files (`.agent/*.md`)

`Learning Mode` defaults to `OFF`. Turn it on per task by setting `Learning Mode: CAPTURE` or `Learning Mode: APPLY` in `.agent/PLAN.md` (or by explicit prompt instruction).
Continuity checkpoints default to sprint closeout, pre-git-cycle, session end, and "context feels ~50% full" as a heuristic trigger.

### Global-level home folder (optional)
- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/*.md`

## Vendor Docs Workflow
- Keep project-curated vendor integration guidance in `docs/vendor/<vendor>.md`.
- Include `Last verified: YYYY-MM-DD` and official source links in each vendor file.
- Agents should read `docs/vendor/` first for vendor/API/security setup work, then verify against current official docs when recency matters.

## Contract Pipeline and Optional Integrations
- `docs/workflows/contracts.md` defines the typed artifact header, continuity checkpoint rules, and cross-artifact linkage rules.
- Required stage order: `PLAN -> TEST -> REVIEW -> HANDOFF`.
- Optional stage-skill integration (gstack-inspired) is additive and must keep file-based fallback behavior.

## Memory
- `docs/architecture/memory-and-indexing-guide.md` explains which memory/indexing layer owns which facts and when to enable optional layers.
- Source code, tests, runtime behavior, and active state artifacts remain the source of truth.
- Continuity is **one file**: `.agent/HANDOFF.md` carries the current baton pass on top, with a newest-first dated Session Timeline below a STOP marker. `.agent/PLAN.md` holds the goal, assumptions, and task checklist.
- `.agent/LEARNINGS.md` is default-off and validation-gated: capture a reusable observation only when `Learning Mode` is `CAPTURE` or `APPLY`, and promote a lesson only after it recurs at least twice or you confirm it.
- `.agent/integrations/run-checkpoint.sh` is an advisory printer — it lists the required `PLAN`/`HANDOFF` updates at sprint closeout, pre-git-cycle, or context pressure. It does not write state.
- Wiki mode and Graphify are Tier 2 orientation/indexing layers; generated claims stay advisory until verified against source.

Examples:
- Local artifact: a handoff records that matter records are created only after `conflict_check.status = approved`, why draft matters for rejected intakes were rejected, what tests proved it, and what remains open.
- Session timeline: the same `.agent/HANDOFF.md` keeps a short, newest-first dated entry below the STOP marker so a future session can recover what happened without rereading every artifact.
- Manual wiki (Tier 2): use curated pages for stable codebase maps, domain glossary, architecture notes, and cross-links that humans may want to edit.
- Graphify (Tier 2): use generated `graphify-out/GRAPH_REPORT.md` and focused graph queries for first-pass orientation on larger repos, then verify the result in source before implementation.
- Non-developer path: ask the agent to "index this codebase with Graphify" (or run `/possiblaw-starter:scale`). The project contract tells the agent to configure `.agent/WIKI.md`, create safe ignore rules, install Graphify only with approval if missing, run the graph build, and report where the output lives.

> Note: a retrieval backend such as MemPalace is a *possible future optional layer* over completed local artifacts; it is not shipped today.

## Optional Wiki Mode
- `docs/workflows/wiki.md` defines how to use a persistent wiki for faster startup context.
- Wiki mode is for orientation and synthesis, not authority; source code and tests remain authoritative.
- Supports both in-repo wiki files and external Obsidian vaults on local disk.
- Wiki backend defaults to `manual`; `graphify` is an optional generated graph/wiki backend.
- Graphify output such as `graphify-out/GRAPH_REPORT.md` and `graphify-out/graph.json` is advisory until verified against source.
- Do not install Graphify always-on assistant hooks, git hooks, or watch mode without explicit user approval.
- To enable it in a repo, set `Enabled: ON` and update `Vault root (absolute)` in `.agent/WIKI.md`.
- After vault setup, the wiki root is generated with `{vault_root}/codebases/{repo_name}` and reused for handoff sync.

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

## Continuity Checkpoint Helper

Flag a sprint-closeout or pre-git checkpoint in a target repo:

```bash
# from inside target repo
./.agent/integrations/run-checkpoint.sh --reason sprint-closeout

# explicit target repo path
/path/to/your/repo/.agent/integrations/run-checkpoint.sh /path/to/your/repo --reason pre-git-cycle
```

The helper does not invent summaries. It is an advisory checklist printer: it flags the required `.agent/PLAN.md` and `.agent/HANDOFF.md` updates (Current Baton plus a prepended Session Timeline entry), reads learning mode, and shows git scope. It does not write state and does not call any backend.

## Repository Layout

```text
packs/
  project/                 # Repo-level files
    docs/roles/            # Canonical host-agnostic role contracts
    docs/vendor/           # Local vendor integration references
    docs/workflows/        # Evals, contracts, token management, and indexing guidance
    .claude/skills/        # Repo-local workflow skills
    .agent/integrations/   # Local advisory checkpoint helper (run-checkpoint.sh)
  global/claude/           # ~/.claude curated files
  global/codex/            # ~/.codex curated files
scripts/                   # Bash only (macOS + Linux)
  bootstrap-project.sh
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
- Launch support is macOS and Linux only. Scripts are bash-only; Windows/PowerShell support has been dropped.
