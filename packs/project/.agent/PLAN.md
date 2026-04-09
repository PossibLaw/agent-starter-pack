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

## Milestones
| Milestone | Owner | Status | Acceptance Check |
| --- | --- | --- | --- |
| Define requirements | | IN_PROGRESS | Objective and acceptance are explicit |
| Implement changes | | PENDING | Requested files updated |
| Validate outcomes | | PENDING | Checks executed with receipts |
| Handoff | | PENDING | Risks and next actions documented |

## Exit Criteria
- Requested outputs complete and validated.
- Remaining blockers documented.
