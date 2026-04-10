# Wiki Mode (Optional)

Use this mode when repo orientation costs too much time each session.
Default is `OFF`.

## Purpose

A wiki is a persistent, LLM-maintained knowledge layer that accelerates context loading.
It is not a replacement for source code verification.

## Trust Order (Required)

1. Source code, tests, and runtime behavior
2. Active state artifacts (`PLAN.md`, `TEST.md`, `REVIEW.md`, `HANDOFF.md`)
3. Curated wiki pages and summaries with source citations
4. Generated graph/wiki output, including Graphify reports and query results

If wiki content conflicts with code, treat wiki content as stale and update it.

## Backend Selection

Configure the backend in `.agent/WIKI.md`:

- `manual`: the default Markdown/Obsidian workflow. Agents or humans maintain `index.md`, `log.md`, and `pages/*`.
- `graphify`: optional generated graph backend. Graphify may create `graphify-out/`, `GRAPH_REPORT.md`, `graph.json`, cache files, visualizations, and optional wiki pages.

Do not enable service-backed or always-on memory/indexing by default. Ix is intentionally out of scope for this Starter Pack workflow unless the project later adopts a separate advanced integration.

## Setup

You may keep the wiki:
- Inside the repo (example: `docs/wiki/`)
- In an external Obsidian vault on local disk
- As local Graphify output under `graphify-out/` when `Wiki backend` is `graphify`

Required config file:
- `.agent/WIKI.md` stores `Enabled`, `Wiki backend`, vault path, wiki root, Graphify output paths, and sync rules.

Recommended core files:
- `index.md` (topic/page index)
- `log.md` (append-only operations log)
- `pages/*` (entity/concept/project pages)

Path convention:
- `wiki_root = {vault_root}/codebases/{repo_name}`
- First-time setup should write this path into `.agent/WIKI.md`.

## Startup Flow (Wiki Enabled)

1. Read `.agent/WIKI.md`, then active `HANDOFF.md` and `PLAN.md`.
2. If `Wiki backend` is `graphify` and `graphify-out/GRAPH_REPORT.md` exists, read it for orientation.
3. Read configured wiki index and 1-3 relevant wiki pages when a wiki root is configured.
4. Verify wiki and graph claims against live code before editing files.
5. Execute task and checks.
6. Update wiki pages and append `log.md` with what changed.

For `manual`, the wiki index is the main entry point.

For `graphify`, use `GRAPH_REPORT.md` for high-level structure and focused graph queries for specific questions. Sync generated pages into a manual wiki only when the team explicitly wants that extra artifact. Do not paste raw `graph.json` wholesale into prompts.

## Graphify Flow (Optional)

Use Graphify when generated structure would reduce orientation time. Do not use it as the default path for small repos or simple tasks.

Before graphing:
1. Confirm `Wiki backend: graphify` in `.agent/WIKI.md`.
2. Create or review `.graphifyignore`.
3. Exclude secrets, `.env*`, generated files, dependency/vendor folders, build outputs, caches, logs, private client exports, and raw client data.
4. Ask before installing Graphify, assistant hooks, git hooks, watch mode, or any always-on integration.

Allowed generated outputs:
- `graphify-out/`
- `graphify-out/GRAPH_REPORT.md`
- `graphify-out/graph.json`
- `graphify-out/cache/`
- optional Graphify-generated wiki pages

Generated output is advisory. Source code, tests, runtime behavior, and active state artifacts remain higher authority.

## Graphify Indexing Request Contract

Use this contract when a non-developer user asks for "Graphify indexing", "codebase indexing", "create a codebase graph", "make a wiki graph", or similar wording.

The agent should do the setup and run the workflow. Do not hand the user a list of developer commands unless blocked by permissions or missing approvals.

Required steps:

1. Resolve the repo root with `git rev-parse --show-toplevel` and confirm it is not a temp directory.
2. Read `.agent/WIKI.md` and this file.
3. Update `.agent/WIKI.md` so `Enabled` is `ON` and `Wiki backend` is `graphify`.
4. Set `Graphify output root` to `graphify-out/` unless the user requested another path.
5. Create or update `.graphifyignore` before running Graphify.
6. Add `graphify-out/` to `.gitignore` unless the user explicitly wants generated graph output committed.
7. Check whether the `graphify` command is available.
8. If Graphify is missing, ask for approval before installing the official package. The upstream project currently documents `pip install graphifyy` as the official PyPI install and `graphify` as the CLI command.
9. Run a one-time graph build for the repo root, normally `graphify .`.
10. If the user asked for Obsidian output, use Graphify's Obsidian option and write to the configured vault path. Otherwise keep output in `graphify-out/`.
11. Read `graphify-out/GRAPH_REPORT.md` enough to confirm the graph was created.
12. Update `.agent/WIKI.md` Last Sync with timestamp, output root, and notes.
13. Report the exact output paths and remind the user that generated graph claims must be verified against source before implementation.

Baseline `.graphifyignore`:

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
coverage/
.cache/
graphify-out/
.git/
.claude/
.agent/
```

Do not install these unless the user explicitly asks for them:
- always-on assistant hooks
- git hooks
- watch mode
- MCP server
- Neo4j export or push
- Obsidian sync

Expected local output:

```text
graphify-out/
├── graph.html
├── GRAPH_REPORT.md
├── graph.json
└── cache/
```

Final response should be short and non-technical:
- state whether indexing completed
- give the output folder
- identify the report file to open first
- list any skipped optional integrations
- list any blocker and the exact approval or missing dependency needed

For "review the entire repo" requests:
- Start with wiki index and map pages first, then verify critical claims in code.

## Source Ingest Flow

When new source material is added:
1. Add raw source reference to `log.md`.
2. Update relevant wiki pages with summaries and cross-links.
3. Tag uncertain claims as `UNCONFIRMED`.
4. Record exact file path and timestamp for each new claim.
5. Update `.agent/HANDOFF.md` and `.claude/history.md` with wiki sync details.

## Required Page Metadata

Every wiki page should include:
- Source paths or URLs
- Last verified date (`YYYY-MM-DD`)
- Confidence (`CONFIRMED`, `PROVISIONAL`, `UNCONFIRMED`)

## Wiki Lint (Periodic)

Run a periodic pass to detect:
- stale claims
- contradictions
- orphan pages
- missing source references

Useful baseline command:
- `rg -n "UNCONFIRMED|TODO|TBD|FIXME" docs/wiki`

## Rules

Always:
- Use wiki for orientation, not final authority.
- Verify critical claims in code before implementation.
- Update wiki after validated changes.

Never:
- Ship code based only on wiki summaries.
- Treat generated wiki pages as evidence without source citations.
