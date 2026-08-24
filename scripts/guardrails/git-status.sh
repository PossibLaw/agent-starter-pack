#!/usr/bin/env bash
# SessionStart hook — provides git context at session start.
# Outputs JSON with additionalContext so Claude has repo awareness from the start.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

if [ ! -d "$PROJECT_DIR/.git" ]; then
    # Not a git repo — nothing to report
    exit 0
fi

cd "$PROJECT_DIR"

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
STATUS=$(git status --short 2>/dev/null | head -20 || echo "")
LOG=$(git log --oneline -5 2>/dev/null || echo "")
STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')

CONTEXT="Git context at session start:
Branch: $BRANCH
Stash count: $STASH_COUNT

Recent commits:
$LOG"

if [ -n "$STATUS" ]; then
    CONTEXT="$CONTEXT

Working tree changes:
$STATUS"
fi

# --- Tier 2 scale nudge -------------------------------------------------------
# If this is a large codebase that is not already in Scale mode, append ONE soft
# suggestion to index it with Graphify. Best-effort and non-fatal: it never errors
# if git or .agent/HANDOFF.md is absent, and it is just an informational line.
SCALE_THRESHOLD=50
ALREADY_SCALED=0

if [ -d "graphify-out" ]; then
    ALREADY_SCALED=1
fi
if [ -f ".agent/HANDOFF.md" ] && grep -q "Scale mode: ON" ".agent/HANDOFF.md" 2>/dev/null; then
    ALREADY_SCALED=1
fi

if [ "$ALREADY_SCALED" -eq 0 ]; then
    CODE_RE='\.(py|js|jsx|ts|tsx|go|rs|java|rb|php|c|cc|cpp|cxx|h|hpp|cs|swift|kt|scala|m|mm|sh)$'
    SRC_COUNT=$(git ls-files 2>/dev/null | grep -cE "$CODE_RE" || true)
    SRC_COUNT=${SRC_COUNT:-0}
    if [ "$SRC_COUNT" -gt "$SCALE_THRESHOLD" ]; then
        CONTEXT="$CONTEXT

📈 Large codebase detected ($SRC_COUNT files). Consider /possibnow-dev-harness:scale to index it with Graphify so the agent stops re-reading files."
    fi
fi

# Escape for JSON
CONTEXT_ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": $CONTEXT_ESCAPED
  }
}
EOF

exit 0
