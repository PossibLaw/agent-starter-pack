# CHANGELOG

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
