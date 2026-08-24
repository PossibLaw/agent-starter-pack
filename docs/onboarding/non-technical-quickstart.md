# Non-Technical Quickstart

## What you need
- A terminal on macOS or Linux (on Windows, use WSL or Git Bash).
- A project folder you want to prepare for Claude/Codex.

## Step 1: Download the harness

```bash
git clone https://github.com/PossibLaw/possibnow-dev-harness.git
```

```bash
cd possibnow-dev-harness
```

## Step 2: Add project instruction files to your repo

```bash
./scripts/install-project.sh /path/to/your/repo
```

Example:

```bash
./scripts/install-project.sh ~/Documents/my-new-project
```

Already inside the target repo:

```bash
/path/to/possibnow-dev-harness/scripts/install-project.sh .
```

Notes:
- The installer auto-detects likely command defaults from repo files when possible.
- If needed, override with flags such as `--test`, `--lint`, `--typecheck`, and `--build`.
- The installer keeps `.agent/HANDOFF.md` trackable for team continuity, and every commit must carry it (`git add .agent/HANDOFF.md` before you commit; Claude Code enforces this with a guardrail). Other `.agent/*.md` working-state files remain local by default.

If this repo already had the harness and you want to keep existing progress and handoff files, run:

```bash
./scripts/install-project.sh /path/to/your/repo --preserve-progress
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
