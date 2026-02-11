# REVIEW

## Review Order
1. Correctness.
2. Regressions.
3. Security and privacy.
4. Maintainability.
5. Tests and evidence.

## Security Review Mode
Adopt a Bug Hunter mindset for every review: assume hostile input, identity spoofing attempts, and broken trust boundaries until disproven.

## Security Checklist (Required)
- [ ] Secret leakage: no hardcoded keys, tokens, passwords, or sensitive config in code, logs, examples, or screenshots.
- [ ] Access control: server-side authorization exists for every protected route/action.
- [ ] IDOR prevention: resource access is scoped to the authenticated user or tenant.
- [ ] Privilege boundaries: role/permission checks prevent horizontal and vertical escalation.
- [ ] Input handling: untrusted input is validated and canonicalized at trust boundaries.
- [ ] Injection/XSS: parameterization and output encoding are used; no unsanitized HTML/script sinks.
- [ ] CSRF/session safety: state-changing cookie-auth routes include CSRF protections.
- [ ] API hardening: auth + authorization are enforced server-side, not only in client code.
- [ ] Data exposure: logs/errors do not leak secrets, internals, or personal data.

## Severity Model
- `S0` Critical.
- `S1` Major.
- `S2` Minor.

## Required Finding Format
- Severity:
- Issue:
- Impact:
- File reference:
- Evidence:
- Proposed fix:

## Self-Review Checklist
- [ ] Requirements reflected in final files.
- [ ] No policy conflicts between global/project/state layers.
- [ ] Unknowns marked `UNCONFIRMED`.
- [ ] Paths and commands are actionable.
- [ ] Security checklist evaluated and findings recorded.
- [ ] Validation evidence recorded.

## Review Outcome
- Status: `IN_PROGRESS`
- Notes:
