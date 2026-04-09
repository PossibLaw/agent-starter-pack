---
contract_version: 1
artifact_type: tasks
status: IN_PROGRESS
depends_on:
  - .agent/PLAN.md
produces:
  - active_task_state
  - blockers
feeds_into:
  - .agent/TEST.md
  - .agent/REVIEW.md
  - .agent/HANDOFF.md
memory:
  include_in_memory: true
  tags: [tasks]
---

# TASKS

## Status Legend
- `PENDING`
- `IN_PROGRESS`
- `DONE`
- `BLOCKED`

## Active Tasks
| ID | Task | Owner | Status | Depends On | Blocker |
| --- | --- | --- | --- | --- | --- |
| T1 | Confirm objective, acceptance criteria, and evals | | IN_PROGRESS | | |

## Backlog
| ID | Task | Priority | Status |
| --- | --- | --- | --- |

## Blockers
- None currently.
