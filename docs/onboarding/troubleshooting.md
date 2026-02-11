# Troubleshooting

## "BLOCKED: target directory does not exist"
- Ensure the path passed to `install-project.sh` exists and is a folder.

## "BLOCKED: choose at least one of --claude, --codex, or --all"
- Add one install target flag to `install-global.sh`.

## "permission denied"
- Ensure scripts are executable:
  - `chmod +x scripts/*.sh`

## I installed but want to revert
- Restore from backup files created next to overwritten files:
  - `<file>.bak.<timestamp>`

## Windows users
- Official launch support is macOS + Linux.
- Use manual copy from `packs/project/` and `packs/global/`.
