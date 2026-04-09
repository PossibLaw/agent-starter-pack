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
feeds_into:
  - .claude/history.md
  - .agent/WIKI.md
memory:
  include_in_memory: true
  tags: [handoff]
---

# HANDOFF

## Status
- Current phase:
- Owner:
- Timestamp (ISO):
- Overall status: `IN_PROGRESS`

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

## Do-Not-Reread
- Archive or stale sources to skip unless explicitly requested.

## Contract Links (Required)
- Eval IDs covered:
- Test receipts referenced:
- Review findings referenced:

## Wiki Sync (Required When `.agent/WIKI.md` Enabled)
- Wiki root:
- Wiki index updated: `YES` or `NO`
- Wiki log updated: `YES` or `NO`
- Pages updated:
