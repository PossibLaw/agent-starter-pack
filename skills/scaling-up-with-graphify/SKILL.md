---
name: scaling-up-with-graphify
version: 1.0.0
description: Use when a codebase has grown large (roughly 40–50+ source files) or you are working inside an existing large repo and re-reading files is wasteful; this is the skill behind Tier 2 Scale mode — build a Graphify index once, then query the index instead of re-reading source.
---

# Scaling Up With Graphify

Scale mode (Tier 2) turns on indexed retrieval so the agent **queries an index
instead of re-reading files**. Graphify builds a queryable knowledge graph of the
code plus a pre-summarized wiki layer. Tier 2 is additive — all Tier 1 rules stay on.
Full reference: `docs/workflows/graphify.md`.

## Inputs
- the repo root (`git rev-parse --show-toplevel`)
- confirmation that the codebase is large enough to warrant indexing
- explicit user approval before installing anything

## Steps
1. **Confirm it's worth it.** Only index when the repo is large (~40–50+ source
   files) or orientation keeps costing real time. Small repos stay in Tier 1.
2. **Ask before installing.** Get the user's approval before installing any tool.
3. **Install the Graphify CLI** (package name is `graphifyy` — the double-y is
   correct; the CLI entry point is `graphify`), then confirm with `graphify --version`:
   - `uv tool install graphifyy` (preferred), or
   - `pipx install graphifyy`, or
   - `pip install graphifyy`
4. **Prepare exclusions, then build** from the repo root with the CLI directly (the
   upstream slash skill is not needed): write `.graphifyignore` (baseline in the
   doc; exclude prose and media, keep `tests/`), add `graphify-out/` to
   `.gitignore`, then run `graphify update .` followed by `graphify export wiki`.
   No API key is needed and extraction uses tree-sitter locally, so the code never
   leaves the machine. Use `graphify update . --force` after editing
   `.graphifyignore` or deleting code.
5. **Query the index instead of re-reading files** (wiki first:
   `graphify-out/wiki/index.md`):
   - `graphify affected "path/to/file.ts"`: what depends on it and which tests cover it
   - `graphify explain "path/to/file.ts"`: imports in and out of a module
   - `graphify query "..." --context call --budget 900`: where a mechanism lives (always narrow)
   - `graphify path "A" "B" --undirected`: how two things connect
   - `graphify god-nodes`: the core abstractions
   - optional slash skill, hooks, MCP server, watch mode: explicit approval only
6. **Keep it fresh.** After every merge to `main`: `graphify update .` then
   `graphify export wiki`. Branches are not in the graph until they merge.
7. **Record the mode.** Set `Tier: 2 (Scale)` and `Scale mode: ON` in
   `.agent/HANDOFF.md` with the rebuild rule and the query commands, and set
   `Wiki backend: graphify` in `.agent/WIKI.md`.
8. **Treat output as advisory.** The graph knows structure, not intent. Verify any
   graph- or wiki-derived claim against the source before implementing. If they
   disagree, the source wins.

## Outputs
- a built index under `graphify-out/` with a usable wiki layer
- `.agent/HANDOFF.md` and `.agent/WIKI.md` updated to reflect Scale mode
- the agent answering "where does X live?" and "what does X affect?" by query, not by re-reading files

## Common Mistakes
- installing anything without explicit user approval (the upstream slash skill installs hooks)
- including prose in the graph so headings outnumber code nodes
- excluding `tests/` and losing the "which tests cover this" answer from `affected`
- running `query` without `--context call` and drowning in hundreds of nodes
- re-reading source files after the index already exists
- letting the graph go stale after merges
- treating graph/wiki output as authoritative instead of verifying against source
- enabling Scale mode on a small repo that Tier 1 already handles
