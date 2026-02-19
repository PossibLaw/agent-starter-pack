# Non-Technical Quickstart

## What you need
- A terminal on macOS, Linux, or Windows.
- A project folder you want to prepare for Claude/Codex.

## Step 1: Download this pack

macOS + Linux:

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd PossibLaw-Agent-Starter-Pack
```

Windows (PowerShell 7+):

```powershell
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd PossibLaw-Agent-Starter-Pack
```

## Step 2: Add project instruction files to your repo

macOS + Linux:

```bash
./scripts/install-project.sh /path/to/your/repo
```

Windows (PowerShell 7+):

```powershell
pwsh -File .\scripts\install-project.ps1 C:\path\to\your\repo
```

Example:

```bash
./scripts/install-project.sh ~/Documents/my-new-project
```

```powershell
pwsh -File .\scripts\install-project.ps1 C:\Users\you\Documents\my-new-project
```

Already inside the target repo:

```bash
/path/to/agent-starter-pack/scripts/install-project.sh .
```

```powershell
pwsh -File C:\path\to\agent-starter-pack\scripts\install-project.ps1 .
```

Notes:
- The installer auto-detects likely command defaults from repo files when possible.
- If needed, override with flags such as `--test`, `--lint`, `--typecheck`, and `--build`.

If this repo already had the starter pack and you want to keep progress files (like `.claude/history.md`, `.agent/HANDOFF.md`, `.agent/TASKS.md`), run:

```bash
./scripts/install-project.sh /path/to/your/repo --preserve-progress
```

```powershell
pwsh -File .\scripts\install-project.ps1 C:\path\to\your\repo --preserve-progress
```

## Step 3 (Optional): Install global files for your user account

```bash
./scripts/install-global.sh --codex --claude
```

```powershell
pwsh -File .\scripts\install-global.ps1 --codex --claude
```

## Step 4: Confirm installation

```bash
./scripts/verify-pack.sh
```

```powershell
pwsh -File .\scripts\verify-pack.ps1
```

## If something goes wrong
- Re-run with `--dry-run` to preview actions:
  - `./scripts/install-project.sh /path/to/repo --dry-run`
  - `./scripts/install-global.sh --all --dry-run`
  - `pwsh -File .\scripts\install-project.ps1 C:\path\to\repo --dry-run`
  - `pwsh -File .\scripts\install-global.ps1 --all --dry-run`
- Restore from backups named like `filename.bak.YYYYMMDD-HHMMSS`.
