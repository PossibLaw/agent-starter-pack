# TEST

## Validation Policy
No task is `DONE` without evidence or an explicit waiver.
No behavior change is `DONE` without an explicit eval definition approved by the user or an explicit waiver.
Do not assume eval criteria, fixtures, or expected outputs; mark unknowns as `UNCONFIRMED` and resolve before executing checks.

## Check Matrix
| Change Type | Required Checks | Evidence Required |
| --- | --- | --- |
| Code changes | Build, lint, typecheck, tests (TDD evidence required) | Command output and exit code, plus failing-before/passing-after receipt |
| Feature/behavior changes | End-user eval walkthrough and executable checks | Eval scenarios (Given/When/Then) with expected outcomes, plus execution receipts |
| Instruction-file edits | Structure and consistency review | Section + path verification |
| Process/routing edits | Contract consistency review | No contradictions across files |
| State-artifact edits | Completeness review | Required sections present |
| Security-sensitive changes (auth, data access, input handling, API surface) | Security regression checks from this file | Explicit pass/fail notes for each security check |

## Commands
- `<LINT_COMMAND>`
- `<TYPECHECK_COMMAND>`
- `<TEST_COMMAND>`
- `rg -n "UNCONFIRMED|BLOCKED|TODO" AGENTS.md CLAUDE.md .agent`
- If commands are placeholders, first derive likely commands from repository signals (for example: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, lockfiles, CI config) and record the source used.
- Return `BLOCKED` only if commands remain unresolved after repository analysis; then ask one targeted user question.

## TDD Evidence (Required For Code Changes)
- Record one failing test/eval that captures the behavior gap before implementation.
- Record the same test/eval passing after implementation.
- If refactoring is performed, record that the relevant checks remained passing.

## End-User Eval Walkthrough (Required For New/Changed Behavior)
Before implementation, present evals in plain language so the user can confirm scope and expected behavior.

| Eval ID | User Goal | Given | When | Then | Inputs/Fixtures | Expected Output | How User Verifies |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E1 | | | | | | | |
| E2 | | | | | | | |
| E3 | | | | | | | |

Minimum eval coverage:
- Happy path scenario.
- Edge/boundary scenario.
- Failure or security scenario relevant to the change.

Eval assumptions policy:
- Unknown values must be marked `UNCONFIRMED`.
- Do not invent expected outcomes.
- Resolve unknowns with a targeted user question before running checks.

## Security Validation Commands (When Applicable)
- `npm audit --production` or `pip-audit` (or ecosystem equivalent).
- Auth/access tests that validate cross-user data isolation.
- API/integration tests for server-side auth on protected routes.

## Security Test Checklist (Required For Launch-Or-Deploy Work)
- [ ] No API keys or secrets in frontend bundles, committed files, or examples.
- [ ] `.env` and related secret files are excluded from source control.
- [ ] API routes enforce authentication and authorization server-side.
- [ ] Cross-account access is blocked (validated with two distinct identities).
- [ ] Database is not publicly exposed beyond required network paths.
- [ ] Default service/database credentials are changed.
- [ ] Debug/development mode is disabled in production runtime.
- [ ] Services do not run as root unless explicitly required and documented.
- [ ] Backup/restore procedure exists and has recent validation evidence.
- [ ] Dependencies were reviewed for known vulnerabilities and unresolved findings are documented.

## Expected Outcomes
- Required files and sections exist.
- Checks pass or failures are documented.
- Open issues are explicit.
- TDD evidence shows at least one failing-before/passing-after behavior check for code changes.
- End-user eval walkthrough is documented and aligned with executed checks.

## Failure Handling
Record command, exact error, mitigation attempt, and final status.

## Test Receipts
| Timestamp (ISO) | Command | Result | Notes |
| --- | --- | --- | --- |
