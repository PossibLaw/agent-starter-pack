# Troubleshooting

## "BLOCKED: target directory does not exist"
- Ensure the path passed to `install-project.sh` exists and is a folder.

## "BLOCKED: choose at least one of --claude, --codex, or --all"
- Add one install target flag to `install-global.sh`.

## "permission denied"
- On macOS/Linux, ensure scripts are executable:
  - `chmod +x scripts/*.sh`

## "running scripts is disabled on this system" (Windows)
- Run with PowerShell 7 (`pwsh`) and, if needed, allow local scripts in your current user scope:
  - `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
- Then run the Windows scripts directly:
  - `pwsh -File .\scripts\verify-pack.ps1`

## I installed but want to revert
- Restore from backup files created next to overwritten files:
  - `<file>.bak.<timestamp>`

## I want to update starter-pack files without replacing progress notes
- Re-run project install with:
  - `./scripts/install-project.sh /path/to/repo --preserve-progress`
  - `pwsh -File .\scripts\install-project.ps1 C:\path\to\repo --preserve-progress`

## Windows users
- Use the PowerShell script variants in `scripts/*.ps1`.
