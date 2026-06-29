---
contract_version: 1
artifact_type: plan
status: IN_PROGRESS
depends_on: []
produces:
  - eval_ids
  - assumptions
  - risks
  - milestone_status
feeds_into:
  - .agent/TEST.md
  - .agent/REVIEW.md
  - .agent/HANDOFF.md
memory:
  include_in_memory: true
  tags: [plan]
---

# PLAN

## Current Plan Snapshot (Read First)
Keep the active plan in the sections below. On every checkpoint, update this current plan in place or prepend the newest active note above older active notes. Do not create alternate plan files.

## Objective
- IN_PROGRESS: <Define target outcome>

## Suggested Roles
- `product-strategist` for scope sharpening and success criteria.
- `engineering-planner` for milestones, file impact, and eval IDs.

## Scope
- In scope:
- Out of scope:

## Constraints
- Time:
- Safety:
- Tooling:
- Environment:

## Evals (Definition of Done)
Before implementation, define how we will verify success.

Minimum coverage for any behavior change:
- Happy path
- Edge/boundary
- Failure/security case

If this work involves an LLM/agent/RAG system, also define:
- Trace source (real vs synthetic)
- Target failure categories (if known)

## Learning Mode
- Mode: `OFF` (default)
- Allowed values:
  - `OFF`: do not update learning artifacts.
  - `CAPTURE`: append observations to `.agent/LEARNINGS.md` at task end.
  - `APPLY`: capture observations and propose updates to skills/plugins/instructions.
- Activation:
  - Set mode in this file for the current task, or
  - Explicitly request mode in the user prompt.

## Continuity Checkpoint
- Sprint label: `UNCONFIRMED`
- Run checkpoint when:
  - the sprint is done or paused
  - the session is about to end
  - work is moving into commit, PR, or merge steps
  - context feels roughly 50% full
- Required checkpoint outputs:
  - update milestone statuses in this file
  - refresh `.agent/HANDOFF.md` (Current Baton + prepend one Session Timeline entry)
  - append `.agent/LEARNINGS.md` when learning mode is `CAPTURE` or `APPLY` (gated lessons only)
- Checkpoint helper (optional, advisory checklist only):
  - `.agent/integrations/run-checkpoint.sh --reason sprint-closeout`

## Assumptions
- [ASSUMPTION]

## Risks
- Risk:
  - Impact:
  - Mitigation:

## Open Questions
- Question:
  - Owner:
  - Needed by:

## Task Checklist
Track in-progress, done, blocked, and unconfirmed work items here (this absorbs the former `TASKS.md`).
- [ ] Task — status: `TODO` | `IN_PROGRESS` | `DONE` | `BLOCKED` | `UNCONFIRMED`

## Contract Outputs (Required)
- Eval IDs defined for `E1`/`E2`/`E3` in `.agent/TEST.md`.
- Assumptions marked `CONFIRMED`, `UNCONFIRMED`, or `ASSUMED`.
- Risks include impact and mitigation.
- Milestone statuses reflect current execution state.
- Planning outputs are compatible with the canonical role specs in `docs/roles/`.

## Milestones
| Milestone | Owner | Status | Acceptance Check |
| --- | --- | --- | --- |
| Define requirements | | IN_PROGRESS | Objective and acceptance are explicit |
| Implement changes | | PENDING | Requested files updated |
| Validate outcomes | | PENDING | Checks executed with receipts |
| Handoff | | PENDING | Risks and next actions documented |
| Sprint checkpoint | | PENDING | PLAN and HANDOFF synced before pause or ship |

## Exit Criteria
- Requested outputs complete and validated.
- Remaining blockers documented.

STOP: normal resume context ends here; older entries below are archive.

## Historical Archive
- Move superseded plan notes below this line only when they are no longer active.
