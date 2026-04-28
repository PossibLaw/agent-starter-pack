# CHANGELOG

## 2026-04-28 — v2.0.0 — Plugin packaging + guardrails absorption
- Added Claude Code plugin manifest at `.claude-plugin/plugin.json` (`name: possiblaw-starter`, `version: 2.0.0`); the starter pack is now installable as a single Claude Code plugin while preserving the existing dual-host bootstrap installers for Codex.
- Promoted repo-local workflow skills from `packs/project/.claude/skills/` to top-level `skills/` (`closing-sprint-and-syncing-state`, `running-novice-safe-git-cycle`); added `version: 1.0.0` to each `SKILL.md` frontmatter.
- Promoted host-agnostic agent definitions from `packs/global/claude/.claude/agents/` to top-level `agents/` (11 `.md` files).
- Absorbed runtime guardrails (predecessor: `possiblaw-guardrails` v1.2.2 plugin): copied hooks (`hooks/hooks.json`, `hooks/tier2-hooks.json`), Python/shell scripts (`scripts/guardrails/{validate-bash,protect-files,format-check,blacklist,persist-state,sanitize-input,validate-task,validate-subagent,git-status}`), pytest suite (`tests/guardrails/test_*.py`, 113 tests passing), and the `/possiblaw-starter:guardrails` slash command (`commands/guardrails.md`).
- Updated all `${CLAUDE_PLUGIN_ROOT}/scripts/...` hook command paths to point at the new `scripts/guardrails/` location; updated test `SCRIPT` path constants to `parent.parent.parent / "scripts" / "guardrails" / ...` so pytest runs against the relocated scripts.
- Updated install scripts so `install-project.{sh,ps1}` copy SKILL.md files from top-level `skills/` and `install-global.{sh,ps1}` copy agents from top-level `agents/` (Bash + PowerShell parity preserved). Codex pack assets (`packs/global/codex/.codex/*`, `packs/project/AGENTS.md`, `docs/roles/*`, `docs/workflows/*`, `.agent/` templates) are unchanged.
- Updated `scripts/verify-pack.{sh,ps1}` to require the plugin manifest, top-level `skills/` and `agents/` (>=10 agent .md files), `hooks/hooks.json`, `scripts/guardrails/validate-bash.py` (executable), and `tests/guardrails/test_validate_bash.py`.
- Tier 2 hooks (validate-task, validate-subagent, sanitize-input, persist-state, git-status SessionStart) ship in `hooks/tier2-hooks.json` and remain disabled by default; documented opt-in path in `README.md`.

## 2026-04-22
- Fixed installer cross-platform parity: Bash `install-project.sh` now tracks whether `.agent/TEST.md` was newly copied and uses the same placeholder-replacement condition as the PowerShell installer (`scripts/install-project.sh`).
- Renamed the Claude reviewer wrapper to match the canonical role (`packs/global/claude/.claude/agents/reviewer.md`, previously `review-agent.md`); updated references in `scripts/verify-pack.sh`, `scripts/verify-pack.ps1`, `packs/project/docs/roles/README.md`, and `packs/project/CLAUDE.md`.
- Collapsed the duplicated `Contract Pipeline` and `Continuity Checkpoint Contract` bodies in `packs/project/CLAUDE.md` and `packs/project/AGENTS.md` into short pointers to the canonical source (`packs/project/docs/workflows/contracts.md`).
- Added parity governance sections to `packs/project/CLAUDE.md` so Claude and Codex templates now mirror each other: `Tool Ownership`, `Canonical Roles`, aligned `Routing Rules`, and `Security Review Contract`.
- Extracted the Graphify Indexing Request Contract out of `packs/project/docs/workflows/wiki.md` into a dedicated `packs/project/docs/workflows/graphify.md`; added an explicit note that the upstream PyPI package is `graphifyy` (CLI entry point `graphify`); updated installer/verify scripts, README, architecture docs, and the Startup Contract in both CLAUDE.md and AGENTS.md to point at the new file.
- Added `packs/project/docs/glossary.md` with 25+ beginner-friendly definitions (roles, artifacts, TDD/evals, trust boundary, IDOR/CSRF, UNCONFIRMED, BLOCKED); linked from Startup Contract in CLAUDE.md and AGENTS.md.
- Shipped stub MemPalace hooks (`packs/project/.agent/integrations/mempalace-ingest.{sh,ps1}`) so the advertised integration point is self-documenting; updated `packs/project/.agent/integrations/README.md` to describe the stubs, and added them to installer copy lists and `scripts/verify-pack.{sh,ps1}` required-file checks.
- Filled the empty `evals.md` eval-table with a concrete worked example (Export contacts as CSV — happy, edge, failure/security) to anchor the beginner audience.
- Removed a tracked macOS artifact (`.DS_Store`) from `packs/project/.agent/integrations/`.

## 2026-04-21
- Added explicit continuity-checkpoint rules to the Codex and Claude project templates so sprint closeout, pre-git-cycle, session end, and context-pressure checkpoints refresh plan, handoff, and history consistently (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`, `packs/project/.agent/PLAN.md`, `packs/project/.agent/TASKS.md`, `packs/project/.agent/HANDOFF.md`, `packs/project/.claude/history.md`, `packs/project/docs/workflows/contracts.md`).
- Added local checkpoint integration helpers plus a MemPalace hook contract under `.agent/integrations/` (`packs/project/.agent/integrations/README.md`, `packs/project/.agent/integrations/run-checkpoint.sh`, `packs/project/.agent/integrations/run-checkpoint.ps1`).
- Added repo-local workflow skills for sprint closeout/state sync and a novice-safe git cycle (`packs/project/.claude/skills/closing-sprint-and-syncing-state/SKILL.md`, `packs/project/.claude/skills/running-novice-safe-git-cycle/SKILL.md`).
- Updated installers, verification scripts, README, and architecture docs so the new continuity helpers and skills install and validate as part of the pack (`scripts/install-project.sh`, `scripts/install-project.ps1`, `scripts/verify-pack.sh`, `scripts/verify-pack.ps1`, `README.md`, `docs/architecture/file-purpose-map.md`, `docs/architecture/memory-and-indexing-guide.md`).

## 2026-04-09
- Added a canonical host-agnostic role registry plus six shared role contracts for planning, review, validation, and handoff (`packs/project/docs/roles/README.md`, `packs/project/docs/roles/*.md`).
- Updated project templates to route Codex and Claude through the shared role contracts instead of freeform role lists (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`, `packs/project/.agent/PLAN.md`, `packs/project/.agent/TEST.md`, `packs/project/.agent/REVIEW.md`, `packs/project/.agent/HANDOFF.md`, `packs/project/docs/workflows/contracts.md`).
- Replaced weak Claude-side wrappers with role-aligned host adapters and added canonical wrappers for strategy, planning, QA, and release work (`packs/global/claude/.claude/agents/*.md`).
- Updated installers, verification scripts, and top-level docs so the shared role registry installs and validates as part of the starter pack (`scripts/install-project.sh`, `scripts/install-project.ps1`, `scripts/verify-pack.sh`, `scripts/verify-pack.ps1`, `README.md`, `docs/architecture/file-purpose-map.md`).
- Added optional wiki-mode workflow doc for persistent context acceleration with trust order and verification rules (`packs/project/docs/workflows/wiki.md`).
- Added concise wiki-mode pointers in project startup templates while keeping detailed guidance in workflow docs (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`, `packs/project/docs/workflows/contracts.md`).
- Updated installers and verification scripts to include and enforce wiki-mode artifacts (`scripts/install-project.sh`, `scripts/install-project.ps1`, `scripts/verify-pack.sh`, `scripts/verify-pack.ps1`).
- Added `.agent/WIKI.md` starter template for wiki enablement flag, Obsidian vault path, auto-derived wiki root, and sync rules.
- Updated handoff/history templates to capture wiki sync output (`packs/project/.agent/HANDOFF.md`, `packs/project/.claude/history.md`).
- Updated startup and local-continuity rules so wiki configuration is treated as a first-class state artifact (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`, `scripts/install-project.sh`, `scripts/install-project.ps1`, `scripts/verify-pack.sh`, `scripts/verify-pack.ps1`).
- Added a typed workflow contract doc for staged state artifacts and optional integrations (`packs/project/docs/workflows/contracts.md`).
- Updated project templates to enforce pipeline sequencing and optional integration points for raw-mode memory retrieval and stage skills (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`).
- Added structured contract headers to state artifact templates and explicit cross-artifact linkage fields (`packs/project/.agent/PLAN.md`, `packs/project/.agent/CONTEXT.md`, `packs/project/.agent/TASKS.md`, `packs/project/.agent/REVIEW.md`, `packs/project/.agent/TEST.md`, `packs/project/.agent/HANDOFF.md`, `packs/project/.agent/LEARNINGS.md`).
- Updated installers to include the new contracts workflow artifact (`scripts/install-project.sh`, `scripts/install-project.ps1`).
- Expanded pack verification to require the contracts workflow artifact, contract sections, and typed artifact headers (`scripts/verify-pack.sh`, `scripts/verify-pack.ps1`).
- Updated top-level docs to reflect the new contract pipeline and optional memory/skill integration guidance (`README.md`, `docs/architecture/file-purpose-map.md`, `packs/project/docs/workflows/evals.md`).

## 2026-03-03
- Improved installer warning messaging when command inference leaves `UNCONFIRMED` values (`scripts/install-project.sh`, `scripts/install-project.ps1`) with explicit “why” and remediation steps.
- Clarified `.agent/TEST.md` guidance to treat `UNCONFIRMED` commands the same as placeholders (`packs/project/.agent/TEST.md`).
- Moved “Pick the Right Mode” guidance to the top of the quick start and documented the `UNCONFIRMED` warning (`README.md`).
- Added an evals-driven development workflow doc and linked it from project templates (`packs/project/docs/workflows/evals.md`, `packs/project/AGENTS.md`, `packs/project/CLAUDE.md`).

## 2026-03-01
- Enforced repo-root validation and state-file path constraints in project templates (`packs/project/CLAUDE.md`, `packs/project/AGENTS.md`) and global templates (`packs/global/claude/.claude/CLAUDE.md`, `packs/global/codex/.codex/AGENTS.md`).
- Added explicit `BLOCKED + ask` behavior when repo root is unresolved, ambiguous, or inside OS temp directories.
- Standardized required state artifact write paths to `${REPO_ROOT}/.agent/PLAN.md`, `${REPO_ROOT}/.agent/HANDOFF.md`, and `${REPO_ROOT}/.claude/history.md` for both Claude and Codex contracts.
- Added vendor documentation support in the project pack (`packs/project/docs/vendor/README.md`, `packs/project/docs/vendor/supabase.md`) with metadata and official-source requirements.
- Added vendor routing rules to project templates and explicit vendor recency verification rules to global templates.
- Updated project installers (`scripts/install-project.sh`, `scripts/install-project.ps1`) and verification scripts (`scripts/verify-pack.sh`, `scripts/verify-pack.ps1`) to include and enforce vendor documentation artifacts.
- Updated docs (`README.md`, `docs/architecture/file-purpose-map.md`) to document the `docs/vendor/` extension pattern and Supabase as the initial vendor guide.

## 2026-02-20
- Added bootstrap installers (`scripts/bootstrap-project.sh` and `scripts/bootstrap-project.ps1`) that clone the starter pack to a temporary directory and install into the current repo by default.
- Updated project installers (`scripts/install-project.sh` and `scripts/install-project.ps1`) so target path is optional and defaults to `.`.
- Added explicit placeholder-path validation with actionable hints when users leave `/path/to/your/repo` or `C:\path\to\your\repo` unchanged.
- Updated onboarding docs to use no-placeholder quick-start commands and preserve-progress bootstrap examples.
- Updated verification scripts to require bootstrap installer entrypoints.

## 2026-02-19
- Added native Windows PowerShell script variants for project install, global install, pack verification, and learning mode updates.
- Added `--preserve-progress` mode to project installers (`.sh` and `.ps1`) so existing repos can refresh starter-pack files without overwriting progress artifacts.
- Updated verification scripts to require both Bash and PowerShell entrypoints.
- Updated GitHub Actions verification workflow to run on both Linux and Windows.
- Added `.gitattributes` line-ending rules for `.sh` and `.ps1` scripts.
- Updated onboarding and architecture docs to document Windows usage via PowerShell.

## 2026-02-17
- Added optional `.agent/LEARNINGS.md` template to project pack for opt-in learning capture.
- Added explicit `Learning Mode` controls (`OFF`, `CAPTURE`, `APPLY`) to project `AGENTS.md`, `CLAUDE.md`, and `.agent/PLAN.md`.
- Added `scripts/set-learning-mode.sh` helper command to toggle learning mode quickly in `.agent/PLAN.md`.
- Updated `scripts/install-project.sh` and `scripts/verify-pack.sh` to install and validate learning artifacts.
- Updated docs (`README.md`, `docs/architecture/file-purpose-map.md`) to document default-off learning workflow and activation.

## 2026-02-11
- Initial starter-pack structure created.
- Added combined Claude + Codex project/global packs.
- Added installer scripts for project and optional global setup.
- Added verification script.
- Added full reference docs and onboarding/architecture documentation.
- Added TDD and eval contracts to project templates (`packs/project/AGENTS.md`, `packs/project/CLAUDE.md`, `packs/project/.agent/TEST.md`).
- Added no-assumption eval policy and required end-user eval walkthrough format.
- Synced global templates with TDD/eval + low-friction inference guidance (`packs/global/codex/.codex/AGENTS.md`, `packs/global/claude/.claude/CLAUDE.md`).
- Upgraded `scripts/install-project.sh` with repo-based command auto-detection plus explicit override support.
- Updated onboarding docs for one-command install in both new and existing repos.
