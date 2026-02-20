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
  --preserve-progress   Do not overwrite existing progress files (.agent/*, .claude/history.md)
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
DETECTED_STACK="UNCONFIRMED"
USER_PRIMARY_COMMAND=""
USER_TEST_COMMAND=""
USER_LINT_COMMAND=""
USER_TYPECHECK_COMMAND=""
USER_BUILD_COMMAND=""
DRY_RUN=0
PRESERVE_PROGRESS=0

PROGRESS_REL_FILES=(
  ".claude/history.md"
  ".agent/PLAN.md"
  ".agent/CONTEXT.md"
  ".agent/TASKS.md"
  ".agent/REVIEW.md"
  ".agent/TEST.md"
  ".agent/HANDOFF.md"
  ".agent/LEARNINGS.md"
)

detect_node_pm() {
  local dir="$1"
  local pkg="$dir/package.json"

  if [[ -f "$pkg" ]]; then
    if grep -q '"packageManager"[[:space:]]*:[[:space:]]*"pnpm@' "$pkg"; then
      echo "pnpm"
      return
    fi
    if grep -q '"packageManager"[[:space:]]*:[[:space:]]*"yarn@' "$pkg"; then
      echo "yarn"
      return
    fi
    if grep -q '"packageManager"[[:space:]]*:[[:space:]]*"bun@' "$pkg"; then
      echo "bun"
      return
    fi
  fi

  if [[ -f "$dir/pnpm-lock.yaml" ]]; then
    echo "pnpm"
    return
  fi
  if [[ -f "$dir/yarn.lock" ]]; then
    echo "yarn"
    return
  fi
  if [[ -f "$dir/bun.lockb" || -f "$dir/bun.lock" ]]; then
    echo "bun"
    return
  fi

  echo "npm"
}

detect_defaults() {
  local dir="$1"

  if [[ -f "$dir/package.json" ]]; then
    local pm
    pm="$(detect_node_pm "$dir")"
    DETECTED_STACK="node"
    case "$pm" in
      yarn)
        PRIMARY_COMMAND="yarn dev"
        TEST_COMMAND="yarn test"
        LINT_COMMAND="yarn lint"
        TYPECHECK_COMMAND="yarn typecheck"
        BUILD_COMMAND="yarn build"
        ;;
      bun)
        PRIMARY_COMMAND="bun run dev"
        TEST_COMMAND="bun test"
        LINT_COMMAND="bun run lint"
        TYPECHECK_COMMAND="bun run typecheck"
        BUILD_COMMAND="bun run build"
        ;;
      *)
        PRIMARY_COMMAND="${pm} run dev"
        TEST_COMMAND="${pm} test"
        LINT_COMMAND="${pm} run lint"
        TYPECHECK_COMMAND="${pm} run typecheck"
        BUILD_COMMAND="${pm} run build"
        ;;
    esac
    return
  fi

  if [[ -f "$dir/pyproject.toml" || -f "$dir/requirements.txt" || -f "$dir/requirements-dev.txt" || -f "$dir/Pipfile" ]]; then
    DETECTED_STACK="python"
    PRIMARY_COMMAND="UNCONFIRMED"
    TEST_COMMAND="pytest -q"
    LINT_COMMAND="ruff check ."
    TYPECHECK_COMMAND="mypy ."
    BUILD_COMMAND="python -m build"
    return
  fi

  if [[ -f "$dir/go.mod" ]]; then
    DETECTED_STACK="go"
    PRIMARY_COMMAND="go run ."
    TEST_COMMAND="go test ./..."
    LINT_COMMAND="golangci-lint run"
    TYPECHECK_COMMAND="go vet ./..."
    BUILD_COMMAND="go build ./..."
    return
  fi

  if [[ -f "$dir/Cargo.toml" ]]; then
    DETECTED_STACK="rust"
    PRIMARY_COMMAND="cargo run"
    TEST_COMMAND="cargo test"
    LINT_COMMAND="cargo clippy --all-targets --all-features -- -D warnings"
    TYPECHECK_COMMAND="cargo check --all-targets --all-features"
    BUILD_COMMAND="cargo build"
    return
  fi
}

is_progress_rel_file() {
  local rel="$1"
  for progress_rel in "${PROGRESS_REL_FILES[@]}"; do
    if [[ "$rel" == "$progress_rel" ]]; then
      return 0
    fi
  done
  return 1
}

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
      USER_PRIMARY_COMMAND="${2:-}"
      shift 2
      ;;
    --test)
      USER_TEST_COMMAND="${2:-}"
      shift 2
      ;;
    --lint)
      USER_LINT_COMMAND="${2:-}"
      shift 2
      ;;
    --typecheck)
      USER_TYPECHECK_COMMAND="${2:-}"
      shift 2
      ;;
    --build)
      USER_BUILD_COMMAND="${2:-}"
      shift 2
      ;;
    --preserve-progress)
      PRESERVE_PROGRESS=1
      shift
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

# Infer commands to reduce setup friction.
detect_defaults "$TARGET_DIR"

# Explicit CLI flags always win.
if [[ -n "${USER_PRIMARY_COMMAND// }" ]]; then
  PRIMARY_COMMAND="$USER_PRIMARY_COMMAND"
fi
if [[ -n "${USER_TEST_COMMAND// }" ]]; then
  TEST_COMMAND="$USER_TEST_COMMAND"
fi
if [[ -n "${USER_LINT_COMMAND// }" ]]; then
  LINT_COMMAND="$USER_LINT_COMMAND"
fi
if [[ -n "${USER_TYPECHECK_COMMAND// }" ]]; then
  TYPECHECK_COMMAND="$USER_TYPECHECK_COMMAND"
fi
if [[ -n "${USER_BUILD_COMMAND// }" ]]; then
  BUILD_COMMAND="$USER_BUILD_COMMAND"
fi

if [[ -z "${PRIMARY_COMMAND// }" ]]; then PRIMARY_COMMAND="UNCONFIRMED"; fi
if [[ -z "${TEST_COMMAND// }" ]]; then TEST_COMMAND="UNCONFIRMED"; fi
if [[ -z "${LINT_COMMAND// }" ]]; then LINT_COMMAND="UNCONFIRMED"; fi
if [[ -z "${TYPECHECK_COMMAND// }" ]]; then TYPECHECK_COMMAND="UNCONFIRMED"; fi
if [[ -z "${BUILD_COMMAND// }" ]]; then BUILD_COMMAND="UNCONFIRMED"; fi

copy_with_backup() {
  local src="$1"
  local dst="$2"
  local rel="$3"

  if [[ ! -f "$src" ]]; then
    echo "BLOCKED: source file missing: $src"
    exit 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ "$PRESERVE_PROGRESS" -eq 1 && -e "$dst" ]] && is_progress_rel_file "$rel"; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY_RUN preserve: $dst (existing progress file)"
    else
      echo "Preserved: $dst (existing progress file)"
    fi
    return 0
  fi

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

ensure_progress_ignored() {
  local gitignore="$TARGET_DIR/.gitignore"
  local header="# Local agent continuity files (keep local; do not commit)"
  local rel
  local added=0

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ ! -e "$gitignore" ]]; then
      echo "DRY_RUN create: $gitignore"
    fi
    if [[ ! -f "$gitignore" ]] || ! grep -Fxq "$header" "$gitignore"; then
      echo "DRY_RUN append: $gitignore :: $header"
    fi
    for rel in "${PROGRESS_REL_FILES[@]}"; do
      if [[ ! -f "$gitignore" ]] || ! grep -Fxq "$rel" "$gitignore"; then
        echo "DRY_RUN append: $gitignore :: $rel"
      fi
    done
    return 0
  fi

  if [[ ! -e "$gitignore" ]]; then
    touch "$gitignore"
    echo "Created: $gitignore"
  fi

  if ! grep -Fxq "$header" "$gitignore"; then
    if [[ -s "$gitignore" ]]; then
      printf "\n" >>"$gitignore"
    fi
    printf "%s\n" "$header" >>"$gitignore"
    added=1
  fi

  for rel in "${PROGRESS_REL_FILES[@]}"; do
    if grep -Fxq "$rel" "$gitignore"; then
      continue
    fi
    printf "%s\n" "$rel" >>"$gitignore"
    added=1
  done

  if [[ "$added" -eq 1 ]]; then
    echo "Updated: $gitignore (local continuity rules)"
  else
    echo "Unchanged: $gitignore (local continuity rules already present)"
  fi
}

warn_if_progress_files_tracked() {
  local rel
  local tracked=()
  local quoted=()

  if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  for rel in "${PROGRESS_REL_FILES[@]}"; do
    if git -C "$TARGET_DIR" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      tracked+=("$rel")
    fi
  done

  if [[ "${#tracked[@]}" -eq 0 ]]; then
    return 0
  fi

  for rel in "${tracked[@]}"; do
    quoted+=("$(printf '%q' "$rel")")
  done

  echo ""
  echo "WARNING: local continuity files are tracked in git and can still be committed:"
  for rel in "${tracked[@]}"; do
    echo "  - $rel"
  done
  echo "To keep local copies but untrack them, run:"
  echo "  git -C \"$TARGET_DIR\" rm --cached ${quoted[*]}"
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

TEST_FILE_PREEXISTED=0
if [[ -e "$TARGET_DIR/.agent/TEST.md" ]]; then
  TEST_FILE_PREEXISTED=1
fi

copy_with_backup "$PACK_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"
copy_with_backup "$PACK_ROOT/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md"
copy_with_backup "$PACK_ROOT/.claude/history.md" "$TARGET_DIR/.claude/history.md" ".claude/history.md"
copy_with_backup "$PACK_ROOT/.agent/PLAN.md" "$TARGET_DIR/.agent/PLAN.md" ".agent/PLAN.md"
copy_with_backup "$PACK_ROOT/.agent/CONTEXT.md" "$TARGET_DIR/.agent/CONTEXT.md" ".agent/CONTEXT.md"
copy_with_backup "$PACK_ROOT/.agent/TASKS.md" "$TARGET_DIR/.agent/TASKS.md" ".agent/TASKS.md"
copy_with_backup "$PACK_ROOT/.agent/REVIEW.md" "$TARGET_DIR/.agent/REVIEW.md" ".agent/REVIEW.md"
copy_with_backup "$PACK_ROOT/.agent/TEST.md" "$TARGET_DIR/.agent/TEST.md" ".agent/TEST.md"
copy_with_backup "$PACK_ROOT/.agent/HANDOFF.md" "$TARGET_DIR/.agent/HANDOFF.md" ".agent/HANDOFF.md"
copy_with_backup "$PACK_ROOT/.agent/LEARNINGS.md" "$TARGET_DIR/.agent/LEARNINGS.md" ".agent/LEARNINGS.md"
ensure_progress_ignored

if [[ "$DRY_RUN" -eq 0 ]]; then
  replace_placeholders "$TARGET_DIR/AGENTS.md"
  replace_placeholders "$TARGET_DIR/CLAUDE.md"
  if [[ "$PRESERVE_PROGRESS" -eq 0 || "$TEST_FILE_PREEXISTED" -eq 0 ]]; then
    replace_placeholders "$TARGET_DIR/.agent/TEST.md"
  fi
fi

echo ""
echo "DONE: project files installed into $TARGET_DIR"
echo "Resolved values:"
echo "  PRESERVE_PROGRESS=$PRESERVE_PROGRESS"
echo "  DETECTED_STACK=$DETECTED_STACK"
echo "  PROJECT_NAME=$PROJECT_NAME"
echo "  TEAM_OR_OWNER=$TEAM_OR_OWNER"
echo "  PRIMARY_COMMAND=$PRIMARY_COMMAND"
echo "  TEST_COMMAND=$TEST_COMMAND"
echo "  LINT_COMMAND=$LINT_COMMAND"
echo "  TYPECHECK_COMMAND=$TYPECHECK_COMMAND"
echo "  BUILD_COMMAND=$BUILD_COMMAND"
warn_if_progress_files_tracked

if [[ "$PRIMARY_COMMAND" == "UNCONFIRMED" || "$TEST_COMMAND" == "UNCONFIRMED" || "$LINT_COMMAND" == "UNCONFIRMED" || "$TYPECHECK_COMMAND" == "UNCONFIRMED" || "$BUILD_COMMAND" == "UNCONFIRMED" ]]; then
  echo ""
  echo "WARNING: one or more commands are UNCONFIRMED. Update .agent/TEST.md before marking work DONE."
fi
