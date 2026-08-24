---
contract_version: 1
artifact_type: handoff
status: IN_PROGRESS
depends_on:
  - .agent/PLAN.md
  - .agent/TEST.md
  - .agent/REVIEW.md
produces:
  - next_actions
  - open_questions
  - decision_summary
  - session_timeline
feeds_into:
  - .agent/WIKI.md
memory:
  include_in_memory: true
  tags: [handoff]
---

# HANDOFF

This is the shared, version-controlled continuity record, committed with every change it describes — stage it (`git add .agent/HANDOFF.md`) before each commit so teammates and other coding agents inherit the current baton. The **current baton** (where we are + what's next) lives at the top. The **session timeline** (newest-first, dated) lives below the STOP marker. There is no separate history file — keep both here. Never create sidecar continuity files.

On resume: read from the top and stop at the STOP marker. Read the timeline below it only when you explicitly need history.

## Current Baton (Read First)
Refresh this section in place at every checkpoint. Keep the newest actionable state here.

## Status
- Current phase:
- Owner:
- Timestamp (ISO):
- Overall status: `IN_PROGRESS`
- Checkpoint reason: `task-end` | `sprint-closeout` | `pre-git-cycle` | `context-50` | `handoff`
- Tier: `1 (Starter)` | `2 (Scale)`
- Scale mode: `OFF` | `ON`

## Suggested Roles
- `docs-releaser` owns handoff quality, docs alignment, and next-action clarity.

## What Was Completed
- Item:
  - Files:
  - Evidence:

## Decisions
- Decision:
  - Chose:
  - Rejected:
  - Why:
  - Status: `CONFIRMED` or `PROVISIONAL`

## Exact Values and Constraints
- Value:
- Constraint:
- Conditional rule: IF / THEN / BUT / EXCEPT

## Open Questions
- Question:
- Needed from:
- Risk if unanswered:

## Next Actions
1.
2.
3.

## Sprint / Git Cycle
- Sprint label:
- Sprint status: `IN_PROGRESS` | `PAUSED` | `COMPLETE`
- Git cycle status: `NOT_STARTED` | `REVIEWING` | `READY_TO_COMMIT` | `COMMITTED` | `PUSHED` | `PR_OPEN`
- Recommended next git step:

## Learning / Memory
- Learning mode: `OFF` | `CAPTURE` | `APPLY`
- Learnings updated: `YES` | `NO` | `N/A`

## Do-Not-Reread
- Archive or stale sources to skip unless explicitly requested.

## Contract Links (Required)
- Eval IDs covered:
- Test receipts referenced:
- Review findings referenced:

## Wiki Sync (Required When `.agent/WIKI.md` Enabled — Tier 2)
- Wiki root:
- Wiki index updated: `YES` or `NO`
- Pages updated:

STOP: normal resume context ends here; older entries below are archive.

## Session Timeline (Newest First)
Prepend one short entry per checkpoint. Keep only the current resume context above the STOP marker; everything dated goes here.

<!-- Format:
### YYYY-MM-DD — Task title
- Checkpoint reason: task-end | sprint-closeout | pre-git-cycle | context-50 | handoff
- Files changed: ...
- Decisions: ...
- Current state: ...
- Next steps: ...
- Git cycle: not started | reviewing | ready to commit | committed | pushed | PR open
- Learnings: updated | skipped | not enabled
-->

<!-- New timeline entries go here, newest first. -->
