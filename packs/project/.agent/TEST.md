# TEST

## Validation Policy
No task is `DONE` without evidence or an explicit waiver.

## Check Matrix
| Change Type | Required Checks | Evidence Required |
| --- | --- | --- |
| Instruction-file edits | Structure and consistency review | Section + path verification |
| Process/routing edits | Contract consistency review | No contradictions across files |
| State-artifact edits | Completeness review | Required sections present |
| Security-sensitive changes (auth, data access, input handling, API surface) | Security regression checks from this file | Explicit pass/fail notes for each security check |

## Commands
- `<LINT_COMMAND>`
- `<TYPECHECK_COMMAND>`
- `<TEST_COMMAND>`
- `rg -n "UNCONFIRMED|BLOCKED|TODO" AGENTS.md CLAUDE.md .agent`

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

## Failure Handling
Record command, exact error, mitigation attempt, and final status.

## Test Receipts
| Timestamp (ISO) | Command | Result | Notes |
| --- | --- | --- | --- |
