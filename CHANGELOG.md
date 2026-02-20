# CHANGELOG

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
