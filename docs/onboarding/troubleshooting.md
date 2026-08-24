# Troubleshooting

## "BLOCKED: target directory does not exist"
- Ensure the path passed to `install-project.sh` exists and is a folder.

## "BLOCKED: choose at least one of --claude, --codex, or --all"
- Add one install target flag to `install-global.sh`.

## "permission denied"
- On macOS/Linux, ensure scripts are executable:
  - `chmod +x scripts/*.sh`

## I installed but want to revert
- Restore from backup files created next to overwritten files:
  - `<file>.bak.<timestamp>`

## I want to update harness files without replacing progress notes
- Re-run project install with:
  - `./scripts/install-project.sh /path/to/repo --preserve-progress`

## `.agent/HANDOFF.md` does not show up in `git status`
- New installs keep `.agent/HANDOFF.md` trackable while other `.agent/*.md` working-state files remain ignored.
- Re-run the current project installer to remove the exact legacy handoff ignore rule:
  - `./scripts/install-project.sh /path/to/repo --preserve-progress`
- If the handoff remains ignored, find the broader custom rule and narrow it without exposing the other working-state files:
  - `git check-ignore -v .agent/HANDOFF.md`

## "BLOCKED: .agent/HANDOFF.md is untracked" or "has unstaged edits" when committing
- This is the shared-handoff commit guard in Claude Code (`validate-bash` hook). Every commit must carry the current handoff so teammates and other coding agents inherit the baton.
- Fix: refresh the Current Baton at the top of `.agent/HANDOFF.md`, then:
  - `git add .agent/HANDOFF.md`
  - retry the commit (for tracked-but-unstaged edits, `git commit -a` also works)
- The guard never fires outside a git repo or in a repo that has no `.agent/HANDOFF.md`.
- Codex and other AGENTS.md-aware tools have no runtime hook; they follow the same rule from `AGENTS.md` and `docs/workflows/contracts.md`.

## I still have the old `possiblaw-starter` plugin installed
- The plugin was renamed to `possibnow-dev-harness` in v4.0.0 and its slash commands changed to `/possibnow-dev-harness:*`.
  - `/plugin uninstall possiblaw-starter@possiblaw-plugins`
  - `/plugin install possibnow-dev-harness@possiblaw-plugins`

## Windows users
- The harness ships bash scripts only (macOS + Linux). On Windows, run them from WSL or Git Bash.
