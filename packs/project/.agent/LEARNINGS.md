---
contract_version: 1
artifact_type: learnings
status: IN_PROGRESS
depends_on:
  - .agent/PLAN.md
produces:
  - reusable_observations
  - proposed_improvements
feeds_into:
  - AGENTS.md
  - CLAUDE.md
memory:
  include_in_memory: true
  tags: [learning]
---

# LEARNINGS

One bounded, trustworthy file of lessons that earned their place. Use it only when `Learning Mode` is `CAPTURE` or `APPLY`. Default is `OFF`.

## Promotion Gate (Required)
A lesson is added **only** if it passes the gate — otherwise it stays out:
- it **recurred at least twice** (the same correction or failure happened more than once), OR
- the **user explicitly confirmed** it should be a standing rule.

One-off observations, hunches, and "might be useful someday" notes do not qualify. This keeps the file small and reliable so it does not rot. When in doubt, leave it out.

Keep the file bounded: if it grows past a couple dozen lessons, merge or retire the weakest ones rather than appending forever. Lessons are revertible — remove any that stop being true.

## Modes
- `OFF`: do not add entries.
- `CAPTURE`: add gated lessons only; do not edit skills/plugins/instructions.
- `APPLY`: add gated lessons and propose concrete edits for approval.

## Entry Template
### YYYY-MM-DD — <Short lesson title>
- Gate passed by: `recurred ≥2×` | `user-confirmed`
- Context:
- Lesson (generalized principle):
- Evidence (where it recurred / who confirmed):
- Target type: `skill` | `plugin` | `instruction` | `workflow`
- Suggested change:
- Status: `OPEN` | `ACTIONED` | `DECLINED`

## Optional Consolidation ("sleep review")
At sprint closeout you may review the session for repeated corrections or failures and propose bounded edits to this file (and, in `APPLY` mode, to skills/instructions). Require the promotion gate — and human approval for any instruction/skill change — before adopting. Never let a proposed lesson silently change behavior.
