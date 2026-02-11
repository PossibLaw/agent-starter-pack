#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Install project-level agent files into a target repository.

Usage:
  install-project.sh /path/to/target-repo [options]

Options:
  --name <project_name>
  --owner <team_or_owner>
  --primary "<primary_command>"
  --test "<test_command>"
  --lint "<lint_command>"
  --typecheck "<typecheck_command>"
  --build "<build_command>"
  --dry-run
  -h, --help
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TARGET_DIR="$1"
shift

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "BLOCKED: target directory does not exist: $TARGET_DIR"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACK_ROOT="$REPO_ROOT/packs/project"
TS="$(date '+%Y%m%d-%H%M%S')"

if [[ ! -d "$PACK_ROOT" ]]; then
  echo "BLOCKED: missing project pack: $PACK_ROOT"
  exit 1
fi

PROJECT_NAME="$(basename "$TARGET_DIR")"
TEAM_OR_OWNER="${USER:-UNCONFIRMED}"
PRIMARY_COMMAND="UNCONFIRMED"
TEST_COMMAND="UNCONFIRMED"
LINT_COMMAND="UNCONFIRMED"
TYPECHECK_COMMAND="UNCONFIRMED"
BUILD_COMMAND="UNCONFIRMED"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      PROJECT_NAME="${2:-}"
      shift 2
      ;;
    --owner)
      TEAM_OR_OWNER="${2:-}"
      shift 2
      ;;
    --primary)
      PRIMARY_COMMAND="${2:-}"
      shift 2
      ;;
    --test)
      TEST_COMMAND="${2:-}"
      shift 2
      ;;
    --lint)
      LINT_COMMAND="${2:-}"
      shift 2
      ;;
    --typecheck)
      TYPECHECK_COMMAND="${2:-}"
      shift 2
      ;;
    --build)
      BUILD_COMMAND="${2:-}"
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

replace_placeholders() {
  local file="$1"
  PROJECT_NAME="$PROJECT_NAME" \
  TEAM_OR_OWNER="$TEAM_OR_OWNER" \
  PRIMARY_COMMAND="$PRIMARY_COMMAND" \
  TEST_COMMAND="$TEST_COMMAND" \
  LINT_COMMAND="$LINT_COMMAND" \
  TYPECHECK_COMMAND="$TYPECHECK_COMMAND" \
  BUILD_COMMAND="$BUILD_COMMAND" \
  perl -0pi -e 's/<PROJECT_NAME>/$ENV{"PROJECT_NAME"}/g; s/<TEAM_OR_OWNER>/$ENV{"TEAM_OR_OWNER"}/g; s/<PRIMARY_COMMAND>/$ENV{"PRIMARY_COMMAND"}/g; s/<TEST_COMMAND>/$ENV{"TEST_COMMAND"}/g; s/<LINT_COMMAND>/$ENV{"LINT_COMMAND"}/g; s/<TYPECHECK_COMMAND>/$ENV{"TYPECHECK_COMMAND"}/g; s/<BUILD_COMMAND>/$ENV{"BUILD_COMMAND"}/g' "$file"
}

copy_with_backup "$PACK_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md"
copy_with_backup "$PACK_ROOT/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
copy_with_backup "$PACK_ROOT/.claude/history.md" "$TARGET_DIR/.claude/history.md"
copy_with_backup "$PACK_ROOT/.agent/PLAN.md" "$TARGET_DIR/.agent/PLAN.md"
copy_with_backup "$PACK_ROOT/.agent/CONTEXT.md" "$TARGET_DIR/.agent/CONTEXT.md"
copy_with_backup "$PACK_ROOT/.agent/TASKS.md" "$TARGET_DIR/.agent/TASKS.md"
copy_with_backup "$PACK_ROOT/.agent/REVIEW.md" "$TARGET_DIR/.agent/REVIEW.md"
copy_with_backup "$PACK_ROOT/.agent/TEST.md" "$TARGET_DIR/.agent/TEST.md"
copy_with_backup "$PACK_ROOT/.agent/HANDOFF.md" "$TARGET_DIR/.agent/HANDOFF.md"

if [[ "$DRY_RUN" -eq 0 ]]; then
  replace_placeholders "$TARGET_DIR/AGENTS.md"
  replace_placeholders "$TARGET_DIR/CLAUDE.md"
  replace_placeholders "$TARGET_DIR/.agent/TEST.md"
fi

echo ""
echo "DONE: project files installed into $TARGET_DIR"
echo "Resolved values:"
echo "  PROJECT_NAME=$PROJECT_NAME"
echo "  TEAM_OR_OWNER=$TEAM_OR_OWNER"
echo "  PRIMARY_COMMAND=$PRIMARY_COMMAND"
echo "  TEST_COMMAND=$TEST_COMMAND"
echo "  LINT_COMMAND=$LINT_COMMAND"
echo "  TYPECHECK_COMMAND=$TYPECHECK_COMMAND"
echo "  BUILD_COMMAND=$BUILD_COMMAND"
