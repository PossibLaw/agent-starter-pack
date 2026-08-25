---
description: Turn on Tier 2 Scale mode — build a queryable Graphify index of a large codebase so the agent queries the index instead of re-reading files. Walks you through approval, install, build, and recording the mode in your continuity files.
argument-hint: [optional path or note]
allowed-tools: Bash, Read, Edit, Write
---

# /possibnow-dev-harness:scale

Switch this repo into **Scale mode (Tier 2)**. Use it when the codebase has grown
large (roughly 40–50+ source files) or you are working inside an existing large
repo and re-reading files every session is wasteful. Scale mode builds a Graphify
index once, then you **query the index instead of re-reading source**. It is
additive — every Tier 1 rule (PLAN/TEST/REVIEW/HANDOFF, guardrails, simplicity
ladder, token discipline) stays in force.

## How to run it

Follow the `scaling-up-with-graphify` skill end to end. The full reference is
`docs/workflows/graphify.md`. In short:

1. **Confirm it's worth it.** Only index when the repo is genuinely large or
   orientation keeps costing time. Small repos should stay in Tier 1.
2. **Ask before installing anything.** Get the user's approval first.
3. **Install the Graphify CLI** (package `graphifyy` — double-y is correct; CLI is
   `graphify`): `uv tool install graphifyy` (preferred), or `pipx install graphifyy`,
   or `pip install graphifyy`. Confirm with `graphify --version`.
4. **Prepare exclusions, then build** from the repo root with the CLI directly (the
   upstream `/graphify` slash skill is not needed and installs hooks): write
   `.graphifyignore` (baseline in the doc; exclude prose and media, keep `tests/`),
   add `graphify-out/` to `.gitignore`, then run `graphify update .` followed by
   `graphify export wiki`. No API key needed; tree-sitter extraction is local so
   code never leaves the machine. Use `--force` after editing `.graphifyignore`.
5. **Query instead of re-reading:** `graphify affected "path"` (dependents and the
   tests that cover them), `graphify explain "path"`, `graphify query "..."
   --context call --budget 900`, `graphify path "A" "B" --undirected`,
   `graphify god-nodes`; read the wiki layer first at `graphify-out/wiki/index.md`.
6. **Keep it fresh:** `graphify update .` then `graphify export wiki` after every
   merge to `main`. Branches are not in the graph until they merge.
7. **Record the mode:** set `Tier: 2 (Scale)` and `Scale mode: ON` in
   `.agent/HANDOFF.md` with the rebuild rule and the query commands, and
   `Wiki backend: graphify` in `.agent/WIKI.md`.

## Contract

- Ask before installing the tool or any optional integration (the upstream slash
  skill and its PreToolUse hooks, MCP server, watch mode, git hooks). Never install
  always-on tooling without explicit approval.
- Treat all graph/wiki output as advisory — verify against source before
  implementing. If they disagree, the source code wins.

If the user passed `$ARGUMENTS`, treat it as the path to index or a note about
scope; otherwise index the current repo root.
