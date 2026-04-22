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
  - refresh `.agent/HANDOFF.md`
  - append `.claude/history.md`
  - append `.agent/LEARNINGS.md` when learning mode is `CAPTURE` or `APPLY`
  - run `.agent/integrations/mempalace-ingest.sh` or `.ps1` only if a local backend was added
- Checkpoint helper (optional):
  - `.agent/integrations/run-checkpoint.sh --reason sprint-closeout`
  - `.agent/integrations/run-checkpoint.ps1 -Reason sprint-closeout`

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
| Sprint checkpoint | | PENDING | PLAN, HANDOFF, and history synced before pause or ship |

## Exit Criteria
- Requested outputs complete and validated.
- Remaining blockers documented.
