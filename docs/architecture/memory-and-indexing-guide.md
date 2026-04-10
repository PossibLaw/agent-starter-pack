# Memory and Indexing Decision Guide

Use this guide to decide which persistence layer should own a fact, when to turn on optional memory/indexing tools, and how Graphify fits into the Starter Pack.

Status: draft decision guide
Last reviewed: 2026-04-10
Graphify source reviewed: https://github.com/safishamsi/graphify

## Short Version

The Starter Pack should stay file-first.

Canonical memory is the local, reviewable file set:
- `.agent/PLAN.md`
- `.agent/TEST.md`
- `.agent/REVIEW.md`
- `.agent/HANDOFF.md`
- `.claude/history.md`

Optional layers must be additive:
- `.agent/LEARNINGS.md` captures reusable process observations only when learning mode is enabled.
- Wiki mode accelerates orientation, but source code and tests remain authoritative.
- MemPalace is an optional retrieval backend over completed local artifacts.
- Graphify is an optional wiki/indexing backend that can generate a graph report, graph JSON, cache, visualization, and optional wiki pages.
- Claude Code native memory is outside the Starter Pack contract and should not become the repo source of truth.

Default recommendation: keep handoff/history on, keep learnings/wiki/MemPalace/Graphify off until a repo has enough repeated context load pain to justify them.

## Trust Order

1. Source code, tests, runtime behavior, and committed configuration
2. Active workflow artifacts: `PLAN.md`, `TEST.md`, `REVIEW.md`, `HANDOFF.md`
3. Curated repo docs and manually maintained wiki pages with source citations
4. `.claude/history.md` and `.agent/LEARNINGS.md`
5. Generated Graphify output and any MemPalace or Claude native memory retrieval

If any lower layer conflicts with a higher layer, trust the higher layer and update or discard the stale lower-layer claim.

## Layer Responsibilities

| Layer | Default | Main job | Owner | Commit? | Read when | Write when |
| --- | --- | --- | --- | --- | --- | --- |
| `AGENTS.md` / `CLAUDE.md` | On | Stable startup rules and routing | Human-maintained template | Yes | Every agent session | Rarely, for policy changes |
| `.agent/PLAN.md` | On demand | Current objective, assumptions, evals, risks | Active task owner | No | Planning or task execution | Before implementation |
| `.agent/TEST.md` | On demand | Validation commands, eval receipts, security checks | QA/implementer | No | Test/validation work | During verification |
| `.agent/REVIEW.md` | On demand | Review findings and security checklist | Reviewer | No | Review work | During review |
| `.agent/HANDOFF.md` | On demand | Current baton pass, decisions, open questions | Final task owner | No | Resume, handoff, parallel worktree | End of meaningful work |
| `.claude/history.md` | On | Append-only timeline and session memory | Any agent finishing work | No | Resume or context recovery | End of meaningful work |
| `.agent/LEARNINGS.md` | Off | Reusable observations and proposed improvements | Agent only when enabled | No | Learning mode tasks | CAPTURE/APPLY mode only |
| Manual wiki | Off | Curated codebase map and concept pages | Agent/human curator | Optional | Deep orientation/repo review | After verified changes |
| Graphify output | Off | Generated graph/index over code/docs/raw materials | Tool-generated | Usually no | Orientation/query acceleration | Explicit graph refresh |
| MemPalace | Off | Retrieval over completed artifacts | Local backend | Backend-specific | Repeated retrieval pain | After completed artifacts |
| Claude native memory | Tool-specific | Personal/global preferences | Claude Code | Outside repo | Personal behavior only | Never for client/repo facts by default |

## How Current Memory Works

### Handoff and History

`HANDOFF.md` is the structured "what matters next" artifact. It should contain current phase, owner, decisions, constraints, open questions, next actions, and links back to eval/test/review evidence.

`.claude/history.md` is the append-only timeline. It preserves what happened across sessions without asking future agents to reread every artifact. It is useful for resuming work, but it should not override an active handoff.

Use this split:
- Current actionable state goes in `.agent/HANDOFF.md`.
- Historical timeline goes in `.claude/history.md`.
- Do not duplicate full plans, test logs, or wiki pages into history.

### Learnings

`.agent/LEARNINGS.md` is not task memory. It is a controlled improvement queue.

Use it only when `Learning Mode` is `CAPTURE` or `APPLY`:
- `CAPTURE`: record concise observations with evidence.
- `APPLY`: record observations and propose concrete changes to skills, plugins, instructions, or workflows.

Do not use learnings for:
- ordinary task status
- decisions needed by the current implementation
- codebase maps
- client facts
- facts that belong in source docs or tests

### MemPalace

MemPalace is currently documented as a default-off backend. The Starter Pack contract says completed file artifacts remain the source of truth, and MemPalace retrieval is advisory.

Use it only when:
- the team repeatedly needs old task context across many sessions
- raw/verbatim retrieval is available
- retrieved entries cite the source artifact path and timestamp

Do not use MemPalace to create a second writable truth store. The write path should be:

1. Complete local artifacts.
2. Append history/handoff.
3. Ingest those completed artifacts into MemPalace.
4. On retrieval, verify against current local files and source code.

### Manual Wiki

The current wiki workflow is a persistent codebase orientation layer. It is for maps, concepts, domain glossary, architecture summaries, and links between files.

Use it when:
- sessions repeatedly spend time rediscovering the same codebase structure
- a repo has enough moving parts that a map saves time
- a review needs a broad starting point before targeted source verification

Keep manual wiki pages citation-heavy:
- source paths or URLs
- last verified date
- confidence level
- explicit `UNCONFIRMED` markers

### Graphify

Graphify should fit as an optional wiki backend, not a replacement for the Starter Pack workflow.

From the upstream README reviewed on 2026-04-10, Graphify can read a folder of code, docs, papers, screenshots, diagrams, and images, then produce `graphify-out/` with a graph visualization, `GRAPH_REPORT.md`, `graph.json`, and cache. It supports `.graphifyignore`, labels relationships as extracted/inferred/ambiguous, has query/path/explain commands, can generate an agent-crawlable wiki with `--wiki`, and has assistant install commands for Codex and Claude Code. It also documents always-on assistant hooks and git hooks.

Starter Pack policy should narrow that:
- Graphify is allowed only when `.agent/WIKI.md` sets `Wiki backend: graphify`.
- Use Graphify output for orientation and focused graph queries.
- Do not install always-on assistant hooks without explicit user approval.
- Do not install Graphify git hooks without explicit user approval.
- Do not run watch mode by default.
- Before graphing, create or verify `.graphifyignore`.
- Exclude secrets, `.env*`, generated files, dependency/vendor folders, build outputs, caches, logs, private client exports, and raw client data.
- Treat `graphify-out/GRAPH_REPORT.md`, `graphify-out/graph.json`, generated wiki pages, and query results as advisory until verified against source code.

Recommended default generated-output policy:
- keep `graphify-out/` local unless the team explicitly decides to commit it
- commit `.graphifyignore` only if it contains project-safe exclusions
- never commit generated output that may include client facts, secrets, or proprietary source summaries

### Claude Code Native Memory

Claude Code memory can be useful for stable personal preferences, but it should not be part of the Starter Pack's repo memory model.

Use it for:
- user-level communication preferences
- stable personal workflow defaults

Do not use it for:
- repo decisions that should be visible in files
- client facts
- API secrets or credentials
- source-code claims
- task status

If Claude memory conflicts with repo files, repo files win.

## Where Each Fact Should Go

| Fact type | Put it here | Not here |
| --- | --- | --- |
| Current task objective | `.agent/PLAN.md` | Wiki, Graphify, Claude memory |
| Current next action | `.agent/HANDOFF.md` | Learnings, Graphify |
| Test command and receipt | `.agent/TEST.md` | History-only notes |
| Review finding | `.agent/REVIEW.md` | Wiki-only notes |
| "What happened last session" | `.claude/history.md` | `AGENTS.md`, `CLAUDE.md` |
| Reusable process improvement | `.agent/LEARNINGS.md` | Handoff/history |
| Architecture overview | Manual wiki or generated Graphify report | Handoff |
| Source-backed codebase map | Manual wiki or Graphify, with source verification | Claude memory |
| Stable repo policy | `AGENTS.md` / `CLAUDE.md` / workflow docs | History |
| Personal preference | Tool-native user memory | Repo docs |

## Narrowing Recommendations

### Baseline For Most Repos

Keep:
- `AGENTS.md` and `CLAUDE.md`
- `.agent/PLAN.md`, `.agent/TEST.md`, `.agent/REVIEW.md`, `.agent/HANDOFF.md`
- `.claude/history.md`
- `docs/workflows/contracts.md`
- `docs/workflows/wiki.md`

Default off:
- `.agent/LEARNINGS.md`
- manual wiki
- Graphify
- MemPalace
- Claude native memory for repo facts

### Add Manual Wiki When

- the same codebase overview is needed repeatedly
- the repo has stable concepts worth curating
- humans want editable Obsidian-style pages

Manual wiki is the first optional indexing layer because it is simple, file-based, reviewable, and easy to prune.

### Add Graphify When

- the repo is large enough that manual wiki creation is slow
- you need a quick first-pass map over code/docs/raw materials
- graph queries would save more time than maintaining hand-written pages
- generated output can be safely kept local or reviewed before commit

Graphify should produce input to wiki mode, not new policy. Its report can seed manual wiki pages after verification.

For non-developer users, the intended prompt is simple:

```text
Index this codebase with Graphify.
```

The agent should then follow the Graphify Indexing Request Contract in `docs/workflows/wiki.md`: enable Graphify in `.agent/WIKI.md`, create safe ignore rules, ask before installing missing tooling, run a one-time graph build, and report the generated output paths.

### Add MemPalace When

- the team needs retrieval across many completed tasks
- file search through history/handoffs is no longer enough
- the backend can retrieve verbatim snippets with artifact citations

MemPalace should index completed artifacts, not raw repo content by default.

### Use Claude Native Memory Sparingly

Do not depend on it for repo continuity. It is not shared, reviewable, or guaranteed to match local files.

## Suggested Operating Model

```yaml
memory_model:
  source_of_truth:
    - source_code
    - tests
    - runtime_behavior
    - .agent/PLAN.md
    - .agent/TEST.md
    - .agent/REVIEW.md
    - .agent/HANDOFF.md
  session_timeline: .claude/history.md
  learning_mode: OFF # OFF | CAPTURE | APPLY
  wiki_mode: OFF # OFF | ON
  wiki_backend: manual # manual | graphify
  mempalace: OFF
  claude_native_memory_for_repo_facts: OFF
```

## Decision Questions

Use these before adding or enabling a memory/indexing layer:

1. What repeated work will this remove?
2. What file remains the source of truth?
3. Is the output local, reviewable, and easy to delete?
4. Could the output contain client data, secrets, or proprietary summaries?
5. Who updates stale claims?
6. What command verifies generated claims against source?
7. What is the off switch?

If any answer is unclear, keep the layer off.

## Proposed Starter Pack Direction

1. Keep the file-based contract pipeline as canonical.
2. Keep learnings, manual wiki, Graphify, and MemPalace default-off.
3. Add `Wiki backend: manual | graphify` to `.agent/WIKI.md`.
4. Treat Graphify as a backend for wiki/index generation, with no always-on hooks unless explicitly approved.
5. Do not add Ix to the Starter Pack for now.
6. Prefer pruning duplicate memory over adding another backend.
7. Require generated indexes to cite source files and be verified before they influence implementation.
