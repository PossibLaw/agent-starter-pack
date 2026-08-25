# Graphify Indexing (Tier 2 — Scale Mode)

Graphify is the engine behind **Tier 2 Scale mode**. It reads your source files,
builds a queryable knowledge graph, and writes a pre-summarized **wiki layer** plus
a JSON graph. The whole point: once the index exists, **query the index instead of
re-reading files**. On a large repo that is dramatically cheaper than re-reading
source every session.

(Reference: Graphify CLI 0.9.x; commands below verified 2026-08-24 against
`graphify 0.9.49`. PyPI package is `graphifyy` — the double-y is correct. The CLI
entry point is `graphify`. Upstream: <https://github.com/safishamsi/graphify>.)

Source of truth is always live code and tests. Graphify output is **advisory** and
must be verified against source before you implement anything. The graph knows
**structure** (what imports, calls, and contains what); it does not know intent.
Ask it "what depends on X", not "which files break rule Y".

## When to Use

Turn this on with `/possibnow-dev-harness:scale` (or by following this doc with the
CLI directly) when:

- the repo is large (roughly 40–50+ source files) and "where does X live?" keeps
  costing real search time, or
- you're working inside an existing large codebase across several sessions.

Skip it (stay in Tier 1) when:

- the repo is small or the task is narrowly scoped,
- the user hasn't asked for persistent context, or
- a generated artifact would just add confusion over what's authoritative.

## Install

The agent does the setup — don't hand a non-developer a wall of commands unless
you're blocked on permissions. **Ask for approval before installing anything.**

Install the CLI (package `graphifyy`, command `graphify`), then confirm it:

```bash
uv tool install graphifyy   # preferred
# or
pipx install graphifyy
# or
pip install graphifyy
graphify --version
```

## Build the Index

The harness drives the CLI directly. The upstream `/graphify` slash skill is not
required and is not installed by default (see Optional Integrations).

1. **Write `.graphifyignore` first** (baseline at the bottom of this doc). Exclude
   prose and media (`*.md`, `*.mdx`, images, docs and content folders) unless you
   specifically want a document graph: a build that includes them turns every
   heading into a node and buries the code. **Keep `tests/` in the graph**: that is
   what makes `graphify affected` list the tests that cover a module, which is
   exactly what a change needs.
2. **Add `graphify-out/` to `.gitignore`** (local only; every developer rebuilds).
3. **Build, then write the wiki layer**, from the repo root:

```bash
graphify update .          # local tree-sitter extraction: no LLM, no API key, code never leaves the machine
graphify export wiki       # writes graphify-out/wiki/index.md + one article per community
```

`graphify update .` is incremental and fast (about 12 s on a 650-file repo). Use
`graphify update . --force` after editing `.graphifyignore` or after a refactor
that deleted code (the plain update refuses to shrink the graph).

## Keep It Fresh

- **After every merge to `main`:** `graphify update .` then `graphify export wiki`.
  For a controller merging PRs this sits right after "watch the deploy to Success".
- `graphify-out/GRAPH_REPORT.md` records the commit the graph was built from
  (`## Graph Freshness`). Compare with `git rev-parse HEAD` when in doubt.
- Feature branches are not in the graph until they merge.

## Query Instead of Re-Reading

**Consult the wiki layer first.** `graphify-out/wiki/index.md` is a pre-summarized,
human-readable memory tier — cheaper to read than the raw graph. Start there for
orientation, then use focused commands:

| Need | Command |
|---|---|
| Orientation: the core abstractions | `graphify god-nodes --top 15` |
| Blast radius before a change: what depends on a module, and which tests cover it | `graphify affected "lib/path/to/file.ts" --depth 2` |
| What a module imports and who imports it | `graphify explain "lib/path/to/file.ts"` |
| Where a mechanism lives (the call graph around a concept) | `graphify query "concept words" --context call --budget 900` |
| How two things connect | `graphify path "a/file.ts" "b/file.ts" --undirected` |

Rules that save tokens:

- Name nodes by repo-relative path when a bare file name is ambiguous (`explain`
  tells you when it is).
- **Always narrow `query`.** Without `--context call` a two-word query returns
  hundreds of nodes and truncates; with it the same question came back as 17 nodes
  and 21 call edges.
- `--budget` caps output tokens. If the answer is over budget, narrow the query
  instead of raising the budget.
- Import graphs are directed; use `--undirected` on `path`.
- Do not expect semantic answers ("which route files export non-handler
  constants"). Write a source guard test for that class of question.
- Only open `graphify-out/graph.json` for targeted lookups. Do not paste it into a
  prompt.

## Optional Integrations (explicit approval required, none installed by default)

- `graphify claude install` (or `graphify install --platform claude [--project]`):
  copies the upstream slash skill, appends a `# graphify` section to `CLAUDE.md`,
  and registers PreToolUse hooks on `Bash|Grep` and `Read|Glob` that nudge toward
  the graph on every call (`--strict` blocks the first raw read per session).
  `--project` writes those hooks into the committed `.claude/settings.json` with an
  absolute path to the graphify binary, which breaks for anyone else who clones.
  The harness rule plus the CLI already cover this; skip it.
- `graphify hook install` (post-commit rebuild), `graphify watch <path>`, the MCP
  server, Neo4j/FalkorDB export, Obsidian sync: always-on or external; skip unless
  the user asks.

## Expected Local Output

```text
graphify-out/
├── wiki/
│   └── index.md        # pre-summarized memory tier — read this first
├── GRAPH_REPORT.md     # corpus check, god nodes, communities, freshness commit
├── graph.json          # the queryable graph
├── graph.html          # optional visual
└── cache/
```

Record the mode after a successful build: set `Tier: 2 (Scale)` and
`Scale mode: ON` in `.agent/HANDOFF.md` (with the rebuild rule and the query
commands so the next agent has them), and `Wiki backend: graphify` in
`.agent/WIKI.md` (with the output root and a Last Sync timestamp).

## Baseline `.graphifyignore`

Create or update this before running Graphify so secrets and noise stay out:

```gitignore
.env
.env.*
*.pem
*.key
*.p12
*.log
node_modules/
vendor/
dist/
build/
.next/
coverage/
.cache/
graphify-out/
.git/
.claude/
.agent/
# prose and media: keep the graph a code graph (delete these lines and rebuild
# with --force if you want docs in the graph)
*.md
*.mdx
*.png
*.jpg
*.svg
docs/
content/
```

Add `graphify-out/` to `.gitignore` unless the user explicitly wants generated
graph output committed.

## Bootstrap Another Repo (copy-paste prompt for any agent)

Paste this into Claude Code or Codex at the root of the repo you want indexed:

```text
Turn on Tier 2 Scale mode for this repo with Graphify, CLI only, no always-on tooling.
1. If `graphify --version` fails, install with `uv tool install graphifyy` (fallback: `pipx install graphifyy`). Print the version.
2. Create `.graphifyignore` at the repo root with: .env, .env.*, *.pem, *.key, *.p12, *.log, node_modules/, vendor/, dist/, build/, .next/, coverage/, .cache/, graphify-out/, .git/, .claude/, .agent/, plus prose and media (*.md, *.mdx, *.png, *.jpg, *.svg, and the docs/ and content/ folders). Keep tests in the graph.
3. Add `graphify-out/` to `.gitignore`.
4. Run `graphify update .` then `graphify export wiki`. Report nodes, edges, communities, and files from `graphify-out/GRAPH_REPORT.md`. If headings dominate the node count, tighten `.graphifyignore` and rerun with `graphify update . --force`.
5. Smoke test: `graphify god-nodes --top 10`, then `graphify affected "<one central file>"` and confirm the dependents are real by opening one.
6. Record in `.agent/HANDOFF.md`: `Tier: 2 (Scale)`, `Scale mode: ON`, the rebuild rule (`graphify update .` + `graphify export wiki` after every merge to main), and the query commands: `graphify affected "<path>"`, `graphify explain "<path>"`, `graphify query "<words>" --context call --budget 900`, `graphify path "<a>" "<b>" --undirected`, `graphify god-nodes`. If `.agent/WIKI.md` exists, set `Wiki backend: graphify`.
7. Do NOT run `graphify install`, `graphify claude install`, `graphify hook install`, or `graphify watch`, and do not start the MCP server. Do not commit `graphify-out/`.
8. Commit `.graphifyignore`, `.gitignore`, and `.agent/HANDOFF.md` together.
Graph output is advisory; source wins.
```

## Contract

- **Ask before installing** the CLI or any optional piece.
- **Output is advisory.** Verify any graph- or wiki-derived claim against the
  source before implementing. If they disagree, the source code wins; treat the
  graph as stale and regenerate or ignore it.
- **Do not install always-on tooling without explicit user approval** — that
  includes the upstream slash skill and its PreToolUse hooks, watch mode, git
  hooks, the MCP server, Neo4j export/push, and Obsidian sync.

## Final Response Shape (Non-Technical)

- state whether indexing completed and the commit it was built from
- give the output folder and name the wiki index to open first
  (`graphify-out/wiki/index.md`)
- list any skipped optional integrations
- list any blocker and the exact approval or missing dependency needed

For "review the entire repo" requests: start with the wiki index, then verify
critical claims in code. See `docs/workflows/wiki.md` for wiki-mode trust order and
`docs/workflows/token-management.md` for why querying the index beats re-reading.
