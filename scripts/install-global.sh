#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Install optional global Claude/Codex instruction files into the user's HOME.

Usage:
  install-global.sh [--claude] [--codex] [--all] [--home /custom/home] [--dry-run]

Options:
  --claude     Install ~/.claude/CLAUDE.md and ~/.claude/agents/*
  --codex      Install ~/.codex/AGENTS.md
  --all        Install both Claude and Codex global files
  --home       Override HOME (useful for testing)
  --dry-run    Print intended actions only
  -h, --help
USAGE
}

INSTALL_CLAUDE=0
INSTALL_CODEX=0
DRY_RUN=0
HOME_OVERRIDE=""
TS="$(date '+%Y%m%d-%H%M%S')"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude)
      INSTALL_CLAUDE=1
      shift
      ;;
    --codex)
      INSTALL_CODEX=1
      shift
      ;;
    --all)
      INSTALL_CLAUDE=1
      INSTALL_CODEX=1
      shift
      ;;
    --home)
      HOME_OVERRIDE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "BLOCKED: unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "$INSTALL_CLAUDE" -eq 0 && "$INSTALL_CODEX" -eq 0 ]]; then
  echo "BLOCKED: choose at least one of --claude, --codex, or --all"
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACK_CLAUDE="$REPO_ROOT/packs/global/claude/.claude"
PACK_CODEX="$REPO_ROOT/packs/global/codex/.codex"

TARGET_HOME="${HOME_OVERRIDE:-$HOME}"

if [[ ! -d "$TARGET_HOME" ]]; then
  echo "BLOCKED: home path does not exist: $TARGET_HOME"
  exit 1
fi

if [[ "$INSTALL_CLAUDE" -eq 1 && ! -d "$PACK_CLAUDE" ]]; then
  echo "BLOCKED: missing Claude pack: $PACK_CLAUDE"
  exit 1
fi

if [[ "$INSTALL_CODEX" -eq 1 && ! -d "$PACK_CODEX" ]]; then
  echo "BLOCKED: missing Codex pack: $PACK_CODEX"
  exit 1
fi

copy_with_backup() {
  local src="$1"
  local dst="$2"

  if [[ ! -f "$src" ]]; then
    echo "BLOCKED: source file missing: $src"
    exit 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY_RUN backup: $dst -> ${dst}.bak.${TS}"
    else
      cp "$dst" "${dst}.bak.${TS}"
      echo "Backed up: $dst -> ${dst}.bak.${TS}"
    fi
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY_RUN copy: $src -> $dst"
  else
    cp "$src" "$dst"
    echo "Copied: $src -> $dst"
  fi
}

if [[ "$INSTALL_CODEX" -eq 1 ]]; then
  copy_with_backup "$PACK_CODEX/AGENTS.md" "$TARGET_HOME/.codex/AGENTS.md"
fi

if [[ "$INSTALL_CLAUDE" -eq 1 ]]; then
  copy_with_backup "$PACK_CLAUDE/CLAUDE.md" "$TARGET_HOME/.claude/CLAUDE.md"

  for agent_file in "$PACK_CLAUDE/agents"/*.md; do
    copy_with_backup "$agent_file" "$TARGET_HOME/.claude/agents/$(basename "$agent_file")"
  done

  if [[ -f "$PACK_CLAUDE/agents/install.sh" ]]; then
    copy_with_backup "$PACK_CLAUDE/agents/install.sh" "$TARGET_HOME/.claude/agents/install.sh"
    if [[ "$DRY_RUN" -eq 0 ]]; then
      chmod +x "$TARGET_HOME/.claude/agents/install.sh"
    fi
  fi
fi

echo ""
echo "DONE: global installation completed"
echo "  HOME=$TARGET_HOME"
echo "  CLAUDE=$INSTALL_CLAUDE"
echo "  CODEX=$INSTALL_CODEX"
