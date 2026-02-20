#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Clone the starter pack to a temporary directory and install project files.

Usage:
  bootstrap-project.sh [target-repo] [install-project options]

Examples:
  bootstrap-project.sh
  bootstrap-project.sh . --preserve-progress
  bootstrap-project.sh /path/to/repo --owner "team-name"

Environment overrides:
  STARTER_PACK_REPO_URL  Git URL to clone (default: official GitHub repo)
  STARTER_PACK_REF       Branch/tag/ref to clone (default: main)
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TARGET_DIR="."
if [[ $# -gt 0 && "$1" != -* ]]; then
  TARGET_DIR="$1"
  shift
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  if [[ "$TARGET_DIR" == "/path/to/your/repo" || "$TARGET_DIR" == "C:\\path\\to\\your\\repo" ]]; then
    echo "BLOCKED: target directory is still a placeholder: $TARGET_DIR"
    echo "Hint: run this command from inside your target repo."
    exit 1
  fi
  echo "BLOCKED: target directory does not exist: $TARGET_DIR"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "BLOCKED: git is required but not found in PATH."
  exit 1
fi

TARGET_DIR_ABS="$(cd "$TARGET_DIR" && pwd)"
REPO_URL="${STARTER_PACK_REPO_URL:-https://github.com/PossibLaw/agent-starter-pack.git}"
REPO_REF="${STARTER_PACK_REF:-main}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-starter-pack.XXXXXX")"
CLONE_DIR="$TMP_ROOT/repo"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

git clone --quiet --depth 1 --branch "$REPO_REF" "$REPO_URL" "$CLONE_DIR"

if [[ ! -x "$CLONE_DIR/scripts/install-project.sh" ]]; then
  echo "BLOCKED: installer script missing or not executable in cloned starter pack."
  exit 1
fi

"$CLONE_DIR/scripts/install-project.sh" "$TARGET_DIR_ABS" "$@"
