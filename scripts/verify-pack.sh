#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

REQUIRED_FILES=(
  "README.md"
  "CHANGELOG.md"
  "scripts/install-project.sh"
  "scripts/install-global.sh"
  "scripts/verify-pack.sh"
  "scripts/set-learning-mode.sh"
  "packs/project/AGENTS.md"
  "packs/project/CLAUDE.md"
  "packs/project/.claude/history.md"
  "packs/project/.agent/PLAN.md"
  "packs/project/.agent/CONTEXT.md"
  "packs/project/.agent/TASKS.md"
  "packs/project/.agent/REVIEW.md"
  "packs/project/.agent/TEST.md"
  "packs/project/.agent/HANDOFF.md"
  "packs/project/.agent/LEARNINGS.md"
  "packs/global/codex/.codex/AGENTS.md"
  "packs/global/claude/.claude/CLAUDE.md"
)

FORBIDDEN_PATTERNS=(
  "packs/global/claude/.claude/debug"
  "packs/global/claude/.claude/projects"
  "packs/global/claude/.claude/cache"
  "packs/global/claude/.claude/history.jsonl"
  "packs/global/codex/.codex/auth.json"
  "packs/global/codex/.codex/history.jsonl"
  "packs/global/codex/.codex/sessions"
)

missing=0
for rel in "${REQUIRED_FILES[@]}"; do
  if [[ ! -e "$REPO_ROOT/$rel" ]]; then
    echo "BLOCKED: missing required file: $rel"
    missing=1
  fi
done
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

for rel in "${FORBIDDEN_PATTERNS[@]}"; do
  if [[ -e "$REPO_ROOT/$rel" ]]; then
    echo "BLOCKED: forbidden path present: $rel"
    exit 1
  fi
done

for script in "$REPO_ROOT/scripts/install-project.sh" "$REPO_ROOT/scripts/install-global.sh" "$REPO_ROOT/scripts/verify-pack.sh" "$REPO_ROOT/scripts/set-learning-mode.sh"; do
  if [[ ! -x "$script" ]]; then
    echo "BLOCKED: script is not executable: ${script#$REPO_ROOT/}"
    exit 1
  fi
done

allowed_placeholders='<(PROJECT_NAME|TEAM_OR_OWNER|PRIMARY_COMMAND|TEST_COMMAND|LINT_COMMAND|TYPECHECK_COMMAND|BUILD_COMMAND)>'
unexpected="$(rg -n '<[A-Z_]+>' "$REPO_ROOT/packs" | rg -v "$allowed_placeholders" || true)"
if [[ -n "$unexpected" ]]; then
  echo "BLOCKED: unexpected placeholder(s) found:"
  echo "$unexpected"
  exit 1
fi

echo "DONE: verification passed"
