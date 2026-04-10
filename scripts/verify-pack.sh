#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

REQUIRED_FILES=(
  "README.md"
  "CHANGELOG.md"
  "scripts/bootstrap-project.sh"
  "scripts/install-project.sh"
  "scripts/install-global.sh"
  "scripts/verify-pack.sh"
  "scripts/set-learning-mode.sh"
  "scripts/bootstrap-project.ps1"
  "scripts/install-project.ps1"
  "scripts/install-global.ps1"
  "scripts/verify-pack.ps1"
  "scripts/set-learning-mode.ps1"
  "packs/project/AGENTS.md"
  "packs/project/CLAUDE.md"
  "packs/project/docs/roles/README.md"
  "packs/project/docs/roles/product-strategist.md"
  "packs/project/docs/roles/engineering-planner.md"
  "packs/project/docs/roles/reviewer.md"
  "packs/project/docs/roles/security-reviewer.md"
  "packs/project/docs/roles/qa-validator.md"
  "packs/project/docs/roles/docs-releaser.md"
  "packs/project/docs/vendor/README.md"
  "packs/project/docs/vendor/supabase.md"
  "packs/project/docs/workflows/evals.md"
  "packs/project/docs/workflows/contracts.md"
  "packs/project/docs/workflows/wiki.md"
  "packs/project/.claude/history.md"
  "packs/project/.agent/PLAN.md"
  "packs/project/.agent/CONTEXT.md"
  "packs/project/.agent/TASKS.md"
  "packs/project/.agent/REVIEW.md"
  "packs/project/.agent/TEST.md"
  "packs/project/.agent/HANDOFF.md"
  "packs/project/.agent/WIKI.md"
  "packs/project/.agent/LEARNINGS.md"
  "packs/global/codex/.codex/AGENTS.md"
  "packs/global/claude/.claude/CLAUDE.md"
  "packs/global/claude/.claude/agents/product-strategist.md"
  "packs/global/claude/.claude/agents/engineering-planner.md"
  "packs/global/claude/.claude/agents/review-agent.md"
  "packs/global/claude/.claude/agents/security-reviewer.md"
  "packs/global/claude/.claude/agents/qa-validator.md"
  "packs/global/claude/.claude/agents/docs-releaser.md"
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

for script in "$REPO_ROOT/scripts/bootstrap-project.sh" "$REPO_ROOT/scripts/install-project.sh" "$REPO_ROOT/scripts/install-global.sh" "$REPO_ROOT/scripts/verify-pack.sh" "$REPO_ROOT/scripts/set-learning-mode.sh"; do
  if [[ ! -x "$script" ]]; then
    echo "BLOCKED: script is not executable: ${script#$REPO_ROOT/}"
    exit 1
  fi
done

has_rg=0
if command -v rg >/dev/null 2>&1; then
  has_rg=1
fi

allowed_placeholders='<(PROJECT_NAME|TEAM_OR_OWNER|PRIMARY_COMMAND|TEST_COMMAND|LINT_COMMAND|TYPECHECK_COMMAND|BUILD_COMMAND)>'
if [[ "$has_rg" -eq 1 ]]; then
  unexpected="$(rg -n '<[A-Z_]+>' "$REPO_ROOT/packs" | rg -v "$allowed_placeholders" || true)"
else
  unexpected="$(grep -RInE -I --exclude-dir='.*' --exclude='.*' -- '<[A-Z_]+>' "$REPO_ROOT/packs" | grep -Ev -- "$allowed_placeholders" || true)"
fi
if [[ -n "$unexpected" ]]; then
  echo "BLOCKED: unexpected placeholder(s) found:"
  echo "$unexpected"
  exit 1
fi

require_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if [[ "$has_rg" -eq 1 ]]; then
    if ! rg -q --fixed-strings "$pattern" "$file"; then
      echo "BLOCKED: $message"
      exit 1
    fi
    return 0
  fi

  if ! grep -Fq -- "$pattern" "$file"; then
    echo "BLOCKED: $message"
    exit 1
  fi
}

require_text "$REPO_ROOT/packs/project/CLAUDE.md" "## Vendor References" "missing vendor section in packs/project/CLAUDE.md"
require_text "$REPO_ROOT/packs/project/AGENTS.md" "## Vendor References" "missing vendor section in packs/project/AGENTS.md"
require_text "$REPO_ROOT/packs/project/docs/roles/README.md" "## Canonical Roles" "missing canonical role table in packs/project/docs/roles/README.md"
require_text "$REPO_ROOT/packs/project/CLAUDE.md" "## Contract Pipeline (Required)" "missing contract pipeline section in packs/project/CLAUDE.md"
require_text "$REPO_ROOT/packs/project/AGENTS.md" "## Contract Pipeline (Required)" "missing contract pipeline section in packs/project/AGENTS.md"
require_text "$REPO_ROOT/packs/project/CLAUDE.md" "## Optional Wiki Mode (Default OFF)" "missing wiki mode section in packs/project/CLAUDE.md"
require_text "$REPO_ROOT/packs/project/AGENTS.md" "## Optional Wiki Mode (Default OFF)" "missing wiki mode section in packs/project/AGENTS.md"
require_text "$REPO_ROOT/packs/project/CLAUDE.md" ".agent/WIKI.md" "missing wiki config pointer in packs/project/CLAUDE.md"
require_text "$REPO_ROOT/packs/project/AGENTS.md" ".agent/WIKI.md" "missing wiki config pointer in packs/project/AGENTS.md"
require_text "$REPO_ROOT/packs/project/docs/workflows/contracts.md" "## Optional Memory Backend (MemPalace)" "missing mempalace section in packs/project/docs/workflows/contracts.md"
require_text "$REPO_ROOT/packs/project/docs/workflows/contracts.md" "## Optional Skill Workflow Integration (gstack-inspired)" "missing gstack section in packs/project/docs/workflows/contracts.md"
require_text "$REPO_ROOT/packs/project/docs/workflows/contracts.md" "## Optional Wiki Mode Integration (Karpathy Pattern)" "missing wiki integration section in packs/project/docs/workflows/contracts.md"
require_text "$REPO_ROOT/packs/project/docs/workflows/wiki.md" "## Trust Order (Required)" "missing trust order section in packs/project/docs/workflows/wiki.md"
require_text "$REPO_ROOT/packs/project/docs/workflows/wiki.md" "## Graphify Indexing Request Contract" "missing graphify indexing request contract in packs/project/docs/workflows/wiki.md"
require_text "$REPO_ROOT/packs/project/.agent/WIKI.md" "artifact_type: wiki_config" "missing wiki config artifact_type in packs/project/.agent/WIKI.md"
require_text "$REPO_ROOT/packs/project/.agent/WIKI.md" 'Vault root (absolute): `UNCONFIRMED`' "missing vault-path setup marker in packs/project/.agent/WIKI.md"
require_text "$REPO_ROOT/packs/project/CLAUDE.md" "Graphify codebase indexing request" "missing graphify startup trigger in packs/project/CLAUDE.md"
require_text "$REPO_ROOT/packs/project/AGENTS.md" "Graphify codebase indexing request" "missing graphify startup trigger in packs/project/AGENTS.md"
require_text "$REPO_ROOT/packs/project/.agent/PLAN.md" "contract_version: 1" "missing contract header in packs/project/.agent/PLAN.md"
require_text "$REPO_ROOT/packs/project/.agent/PLAN.md" "artifact_type: plan" "missing plan artifact_type in packs/project/.agent/PLAN.md"
require_text "$REPO_ROOT/packs/project/.agent/TEST.md" "artifact_type: test" "missing test artifact_type in packs/project/.agent/TEST.md"
require_text "$REPO_ROOT/packs/project/.agent/REVIEW.md" "artifact_type: review" "missing review artifact_type in packs/project/.agent/REVIEW.md"
require_text "$REPO_ROOT/packs/project/.agent/HANDOFF.md" "artifact_type: handoff" "missing handoff artifact_type in packs/project/.agent/HANDOFF.md"
require_text "$REPO_ROOT/packs/global/claude/.claude/CLAUDE.md" "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." "missing vendor recency rule in packs/global/claude/.claude/CLAUDE.md"
require_text "$REPO_ROOT/packs/global/codex/.codex/AGENTS.md" "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." "missing vendor recency rule in packs/global/codex/.codex/AGENTS.md"

echo "DONE: verification passed"
