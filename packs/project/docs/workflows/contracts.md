# Contract Pipeline and Memory

Use this workflow when consistency and handoff quality matter more than speed.

## Canonical Pipeline

Always run state artifacts in this order:

1. `.agent/PLAN.md`
2. `.agent/TEST.md`
3. `.agent/REVIEW.md`
4. `.agent/HANDOFF.md`

`CONTEXT.md` and `TASKS.md` can be updated throughout execution, but they are supporting artifacts.

## Typed State Artifact Header (Required)

Each `.agent/*.md` artifact should keep a YAML header at the top.

Required keys:
- `contract_version`
- `artifact_type`
- `status`
- `depends_on`
- `produces`
- `feeds_into`
- `memory`

Example:

```yaml
---
contract_version: 1
artifact_type: plan
status: IN_PROGRESS
depends_on: []
produces:
  - eval_ids
feeds_into:
  - .agent/TEST.md
memory:
  include_in_memory: true
  tags: [plan]
---
```

## Cross-Artifact Rules (Required)

- `PLAN.md` must define eval IDs before implementation.
- `TEST.md` must reference eval IDs from `PLAN.md`.
- `REVIEW.md` must reference executed checks and receipts from `TEST.md`.
- `HANDOFF.md` must summarize decisions, open questions, and next actions from prior artifacts.
- Do not mark work `DONE` when required upstream artifacts are missing or unresolved.

## Optional Memory Backend (MemPalace)

Default is `OFF`. File artifacts remain the source of truth.

When enabled:
- Ingest completed `PLAN`, `TEST`, `REVIEW`, `HANDOFF`, and `.claude/history.md`.
- Use retrieval in raw/verbatim mode for reliability.
- Treat memory retrieval as advisory; resolve conflicts in favor of current local artifacts.
- Capture citations to source artifact path and timestamp in summaries.

## Optional Skill Workflow Integration (gstack-inspired)

Default is `OFF`. Use only if a matching skill runtime exists in the repo.

When enabled:
- Map stage skills to pipeline phases (plan, test, review, handoff).
- Require every stage skill to emit structured outputs that feed the next artifact.
- Keep skill usage optional with deterministic file-based fallback.
- Keep plugin/runtime-specific behavior out of core repo policy unless explicitly adopted.

## Validation Commands

Use these checks as a baseline:

- `rg -n "^contract_version: 1|^artifact_type:|^depends_on:|^produces:|^feeds_into:" .agent/*.md`
- `rg -n "UNCONFIRMED|BLOCKED|TODO" .agent AGENTS.md CLAUDE.md`
