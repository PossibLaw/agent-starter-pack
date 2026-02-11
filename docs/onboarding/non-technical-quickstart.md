# Non-Technical Quickstart

## What you need
- A terminal on macOS or Linux.
- A project folder you want to prepare for Claude/Codex.

## Step 1: Download this pack

```bash
git clone https://github.com/PossibLaw/agent-starter-pack.git
cd PossibLaw-Agent-Starter-Pack
```

## Step 2: Add project instruction files to your repo

```bash
./scripts/install-project.sh /path/to/your/repo
```

Example:

```bash
./scripts/install-project.sh ~/Documents/my-new-project
```

## Step 3 (Optional): Install global files for your user account

```bash
./scripts/install-global.sh --codex --claude
```

## Step 4: Confirm installation

```bash
./scripts/verify-pack.sh
```

## If something goes wrong
- Re-run with `--dry-run` to preview actions:
  - `./scripts/install-project.sh /path/to/repo --dry-run`
  - `./scripts/install-global.sh --all --dry-run`
- Restore from backups named like `filename.bak.YYYYMMDD-HHMMSS`.
