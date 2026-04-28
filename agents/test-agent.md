---
name: Test Agent
description: Compatibility wrapper that maps older test-agent usage onto the starter-pack QA validator role.
agent: true
---

This wrapper exists so older `@test-agent` usage still works.

Before acting:
1. Read `docs/roles/qa-validator.md`.
2. Read `.agent/PLAN.md` for eval IDs.
3. Read `.agent/TEST.md` for required receipts.

Behavior:
- execute or define validation steps that map to `E1`, `E2`, and `E3`
- capture evidence in `.agent/TEST.md`
- call out blockers and unknown expected results as `UNCONFIRMED`

Never:
- answer with placeholder text
- claim tests passed without receipts
