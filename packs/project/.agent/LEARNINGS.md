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

## Compass (What This File Is For)
Read this first before writing or promoting anything — it is the filter.

- **What I care about capturing:** decisions that cost time, mistakes I keep re-making, judgment calls that aged well or badly, and patterns proven to work more than once.
- **What I do not:** a running diary, one-off trivia I could look up again, or untested hunches. When in doubt, leave it out.

Edit the two lines above to match this repo. Keep it to a few sentences — this is the compass, not the map.

## Promotion Gate (Required)
A lesson is promoted into a category **only** if it passes the gate — otherwise it stays in the Inbox or out entirely:
- it **recurred at least twice** (the same correction or failure happened more than once), OR
- the **user explicitly confirmed** it should be a standing rule.

One-off observations, hunches, and "might be useful someday" notes do not qualify. This keeps the file small and reliable so it does not rot. When in doubt, leave it out.

Keep the file bounded: if it grows past a couple dozen lessons, merge or retire the weakest ones rather than appending forever. Lessons are revertible — remove any that stop being true (or move them to **Retracted / aged badly** if the reversal is itself the lesson).

## Modes
- `OFF`: do not add entries.
- `CAPTURE`: add gated lessons only; do not edit skills/plugins/instructions.
- `APPLY`: add gated lessons and propose concrete edits for approval.

## Categories
Promoted lessons live under one of these headings. Auto-captured notes land in **Inbox** first and are promoted by hand.

- **Decisions & trade-offs**
- **Mistakes & corrections**
- **Patterns that work**
- **Tools & workflow**
- **Open questions**
- **Retracted / aged badly**

## Entry Template
Lead each entry with the takeaway as the heading, so a skim reads like a list of conclusions.

### YYYY-MM-DD — <Short lesson title (the takeaway)>
- Source: `auto` | `manual`
- Gate passed by: `recurred ≥2×` | `user-confirmed`
- Context:
- Lesson (generalized principle):
- Evidence (where it recurred / who confirmed):
- Next time (the action it changes):
- Target type: `skill` | `plugin` | `instruction` | `workflow`
- Suggested change:
- Status: `OPEN` | `ACTIONED` | `DECLINED`

## Inbox (auto-captured)
Staging area for entries written automatically. Nothing here counts as a lesson until it clears the Promotion Gate and is moved by hand into a category above. Triage this list at each review; delete anything that does not earn promotion.

## Review Loop
Auto-capture is only half a learning loop — the review is the other half. Schedule a recurring review (for example a cron job or a `/loop`) to: triage the Inbox, promote or delete each item against the gate, retire weak lessons, and confirm the file still reflects the Compass. Record each pass in the Review log.

### Review log
<!-- One line per review, newest first. e.g. 2026-07-24 — triaged Inbox, promoted 2, retracted 1 -->

## Optional Consolidation ("sleep review")
At sprint closeout you may review the session for repeated corrections or failures and propose bounded edits to this file (and, in `APPLY` mode, to skills/instructions). Require the promotion gate — and human approval for any instruction/skill change — before adopting. Never let a proposed lesson silently change behavior.
