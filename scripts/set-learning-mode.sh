#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Set Learning Mode in a target repository's .agent/PLAN.md.

Usage:
  set-learning-mode.sh <MODE>
  set-learning-mode.sh /path/to/target-repo <MODE>

Modes:
  OFF
  CAPTURE
  APPLY
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

TARGET_DIR="."
MODE_RAW=""

if [[ $# -eq 1 ]]; then
  MODE_RAW="$1"
else
  TARGET_DIR="$1"
  MODE_RAW="$2"
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "BLOCKED: target directory does not exist: $TARGET_DIR"
  exit 1
fi

MODE="$(printf '%s' "$MODE_RAW" | tr '[:lower:]' '[:upper:]')"
case "$MODE" in
  OFF|CAPTURE|APPLY) ;;
  *)
    echo "BLOCKED: invalid mode: $MODE_RAW"
    usage
    exit 1
    ;;
esac

PLAN_FILE="$TARGET_DIR/.agent/PLAN.md"
if [[ ! -f "$PLAN_FILE" ]]; then
  echo "BLOCKED: missing file: $PLAN_FILE"
  exit 1
fi

MODE_LINE="- Mode: \`$MODE\`"
if [[ "$MODE" == "OFF" ]]; then
  MODE_LINE="$MODE_LINE (default)"
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if ! awk -v mode_line="$MODE_LINE" '
  BEGIN {
    in_section = 0
    replaced = 0
  }
  {
    if ($0 ~ /^## Learning Mode$/) {
      in_section = 1
      print
      next
    }
    if (in_section && $0 ~ /^## /) {
      in_section = 0
    }
    if (in_section && $0 ~ /^- Mode:/ && replaced == 0) {
      print mode_line
      replaced = 1
      next
    }
    print
  }
  END {
    if (replaced == 0) {
      exit 2
    }
  }
' "$PLAN_FILE" > "$tmp_file"; then
  echo "BLOCKED: could not find '- Mode:' under '## Learning Mode' in $PLAN_FILE"
  exit 1
fi

cp "$PLAN_FILE" "${PLAN_FILE}.bak.$(date '+%Y%m%d-%H%M%S')"
mv "$tmp_file" "$PLAN_FILE"
trap - EXIT

echo "DONE: set Learning Mode to $MODE in $PLAN_FILE"
