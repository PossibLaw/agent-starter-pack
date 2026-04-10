# CLAUDE.md

Repo Root (absolute path, required): /path/to/your/repo

<PROJECT_NAME> — replace this line with a 2-line project description.

## Startup Contract
1. This file is the only startup instruction. Do not read other files unless triggered.
2. Do the requested task immediately.
3. Load extra files only on trigger:
   - Planning request → `.agent/PLAN.md`
   - Test request → `.agent/TEST.md`
   - Review request → `.agent/REVIEW.md`
   - Handoff, resume, or parallel worktree → `.agent/HANDOFF.md` or `.claude/history.md`
   - Contract workflow, artifact schema, or stage handoff questions → `docs/workflows/contracts.md`
   - Role workflow, routing, or specialization questions → `docs/roles/README.md` plus the relevant role file in `docs/roles/`
   - Wiki mode, Obsidian vault path, or persistent knowledge questions → `.agent/WIKI.md` and `docs/workflows/wiki.md`
   - Graphify codebase indexing request → `.agent/WIKI.md` and `docs/workflows/wiki.md`, then follow the Graphify Indexing Request Contract
   - Learning request, or `Learning Mode` = `CAPTURE`/`APPLY` → `.agent/LEARNINGS.md`
   - Vendor/integration setup or API config → `docs/vendor/`
   - Evals/help defining “done” → `docs/workflows/evals.md`
4. If more repo context is needed, read `.claude/history.md` next — not the whole repo.
5. Global continuity stays in `~/.claude/CLAUDE.md`. Repo continuity is optional and on-demand.

## Repo Root & State File Paths (Required)
1. Before writing any state file (`.agent/PLAN.md`, `.agent/HANDOFF.md`, `.agent/WIKI.md`, `.claude/history.md`), resolve the repo root using `git rev-parse --show-toplevel` and confirm with `pwd`.
2. If the resolved root is under `/tmp`, `/var/folders`, or any OS temp directory, return `BLOCKED` and ask for the real repo root.
3. If multiple repo roots or worktrees are possible, ask the user which repo root to use.
4. If the repo root cannot be resolved, ask the user for the absolute repo root path and do not write any state files until confirmed.
5. Always write the plan to `${REPO_ROOT}/.agent/PLAN.md`.
6. Always write the handoff to `${REPO_ROOT}/.agent/HANDOFF.md`.
7. Always write history to `${REPO_ROOT}/.claude/history.md`.
8. If `.agent/` or `.claude/` is missing, return `BLOCKED` and ask for permission to create them under `${REPO_ROOT}`.
9. When saving, print the absolute path used; if it is not under `${REPO_ROOT}`, stop and ask for correction.

## Session Memory
After completing work, append a summary to `${REPO_ROOT}/.claude/history.md` (local-only, gitignored):
- Date and task title.
- Files changed.
- Key decisions (with status).
- Current state and next steps.

When resuming prior work, read `${REPO_ROOT}/.claude/history.md` first.

## Local Continuity Files (Do Not Commit)
- Keep these files local and out of commits/PRs:
  - `.claude/history.md`
  - `.agent/PLAN.md`
  - `.agent/CONTEXT.md`
  - `.agent/TASKS.md`
  - `.agent/REVIEW.md`
  - `.agent/TEST.md`
  - `.agent/HANDOFF.md`
  - `.agent/WIKI.md`
  - `.agent/LEARNINGS.md`
- If any are already tracked, untrack them with `git rm --cached <path>`.

## Optional Learning Loop (Default OFF)
- Default: `Learning Mode` is `OFF`.
- Turn on for a task by either:
  - setting `Learning Mode` in `.agent/PLAN.md`, or
  - explicit user instruction (`Learning Mode: CAPTURE` or `Learning Mode: APPLY`).
- Mode behavior:
  - `OFF`: no learning entries and no skill/plugin updates.
  - `CAPTURE`: append observations to `.agent/LEARNINGS.md` only.
  - `APPLY`: capture observations and propose specific skill/plugin/instruction updates.
- This is additive. Do not replace `.claude/history.md` or `.agent/HANDOFF.md`.

## Commands
`<PRIMARY_COMMAND>` - Primary local workflow command.
`<TEST_COMMAND>` - Run tests.
`<LINT_COMMAND>` - Run linting.
`<TYPECHECK_COMMAND>` - Run type checks.
`<BUILD_COMMAND>` - Build or package the project.

Run `<LINT_COMMAND> && <TYPECHECK_COMMAND> && <TEST_COMMAND>` before handoff.

## Stack
- Runtime:
- Framework:
- Data layer:
- Testing:
- Tooling:

## Code Map
- Entry point:
- Config files:
- API layer:
- Domain logic:
- Data/storage:
- Tests:

## Agent Routing
- Product framing, CEO-style prioritization, or scope pressure test → `@product-strategist`
- Engineering plan review, architecture, or phased implementation planning → `@engineering-planner`
- Correctness and regression review → `@review-agent`
- Security and trust-boundary review → `@security-reviewer`
- Validation execution and evidence capture → `@qa-validator`
- Handoff, release notes, and docs sync after validated changes → `@docs-releaser`

Supporting specialists:
- Source extraction or fact gathering → `@research-agent`
- Markdown-heavy doc drafting without release ownership → `@docs-agent`

## Contract Pipeline (Required)
- Treat state artifacts as a typed pipeline, not independent notes.
- Execution order: `PLAN.md` → `TEST.md` → `REVIEW.md` → `HANDOFF.md`.
- `PLAN.md` must define eval IDs, assumptions, and risks before implementation.
- `TEST.md` must reference eval IDs from `PLAN.md` and include receipts.
- `REVIEW.md` must reference executed checks and receipts from `TEST.md`.
- `HANDOFF.md` must summarize decisions, open questions, and next actions from upstream artifacts.
- Do not return `DONE` if a required upstream artifact is missing, inconsistent, or unresolved.

## Optional Memory Backend (MemPalace, Default OFF)
- File artifacts in `.agent/*.md` and `.claude/history.md` remain source of truth.
- If a local MemPalace backend is enabled, ingest completed `PLAN/TEST/REVIEW/HANDOFF/history` artifacts after each task.
- Use raw/verbatim retrieval mode for reliability.
- Treat memory retrieval as advisory and resolve conflicts in favor of current local files.

## Optional Skill Runtime Integration (gstack-inspired, Default OFF)
- If stage skills are available, use them to produce structured outputs that feed the next artifact.
- Keep deterministic file-based fallback active at all times.
- Do not require plugin/runtime-specific tooling for baseline operation.

## Optional Wiki Mode (Default OFF)
- Configure vault and wiki paths in `.agent/WIKI.md` before first use.
- Use `docs/workflows/wiki.md` for startup flow, metadata, and lint rules.
- Wiki pages accelerate orientation; source code and tests remain authoritative.
- For full repository review requests, start with `.agent/WIKI.md` and wiki index, then verify in code.

## Vendor References
- For vendor/integration setup, API config, or security guidance, read `docs/vendor/<vendor>.md` first.
- Treat `docs/vendor/*.md` guidance as authoritative over model-memory defaults.
- If the vendor file is missing or stale, consult official vendor docs/release notes before answering.
- Cite the official source URL and source date for recency-sensitive vendor guidance.

## TDD and Eval Contract
- For code changes, use TDD when feasible: start with a failing test/eval, implement the minimum code to pass, then refactor while checks stay green.
- Never assume eval inputs, acceptance criteria, fixtures, or expected outputs; mark unknowns as `UNCONFIRMED` and resolve with a targeted user question.
- For any new or changed behavior, provide an end-user eval walkthrough before implementation using plain language plus Given/When/Then, including happy path, edge case, and failure/security case.
- Minimize user friction: infer likely test/eval commands and fixtures from repository signals first; ask the user only targeted follow-ups for unresolved unknowns.
- If an eval plan is missing or vague, follow `docs/workflows/evals.md` and propose a minimal 3-eval set (happy, edge, failure/security) before implementation.

## Boundary Rules
Always do:
- Keep edits scoped to requested files.
- Reference exact paths and commands.
- Mark unknowns as `UNCONFIRMED`.

Ask first:
- Destructive operations or schema-changing edits.
- Large refactors outside the stated objective.

Never do:
- Invent evidence or claim completion without validation.
- Remove failing tests to force a pass.
- Expose secrets.
- Read instruction files not triggered by the current task.

## Local Norms
- Persist repeated user corrections here so they survive across sessions.
- Do not duplicate higher-layer policy from `~/.claude/CLAUDE.md`.
