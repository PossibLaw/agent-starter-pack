---
contract_version: 1
artifact_type: wiki_config
status: IN_PROGRESS
depends_on: []
produces:
  - wiki_mode
  - wiki_backend
  - vault_root
  - wiki_root
  - graphify_output
  - startup_rule
  - sync_rule
feeds_into:
  - .agent/HANDOFF.md
  - .claude/history.md
memory:
  include_in_memory: true
  tags: [wiki, config]
---

# WIKI

## Mode
- Enabled: `OFF`
- Wiki backend: `manual`

## Paths
- Vault root (absolute): `UNCONFIRMED`
- Vault root required for: `manual` or Graphify page sync
- Repo root (absolute): `UNCONFIRMED`
- Repo name: `UNCONFIRMED`
- Wiki root (absolute): `UNCONFIRMED`
- Wiki index file: `UNCONFIRMED`
- Wiki log file: `UNCONFIRMED`
- Graphify output root: `graphify-out/`
- Graphify report file: `graphify-out/GRAPH_REPORT.md`
- Graphify graph file: `graphify-out/graph.json`

## Path Convention
- Default wiki root pattern: `{vault_root}/codebases/{repo_name}`
- Default index file: `{wiki_root}/index.md`
- Default log file: `{wiki_root}/log.md`

## Resolution Rules (Required)
1. `Wiki backend` must be `manual` or `graphify`. Default to `manual`.
2. If `Enabled` is `ON`, `Wiki backend` is `manual`, and `Vault root` is `UNCONFIRMED`, ask one targeted user question for the absolute vault path.
3. After `Vault root` is set, compute and write `Wiki root`, `Wiki index file`, and `Wiki log file`.
4. If `Wiki backend` is `graphify`, verify `Graphify output root` and `.graphifyignore` before graphing. `Vault root` is required only if Graphify-generated pages will be synced to a manual wiki.
5. Mark `status` as `CONFIRMED` after required paths for the chosen backend are valid and writable.

## Startup Rule (Required When Enabled)
- For full repository review requests, read `.agent/WIKI.md`, then `PLAN/HANDOFF`, then the wiki index if configured, then verify in source code.
- If `Wiki backend` is `graphify` and `graphify-out/GRAPH_REPORT.md` exists, read it for orientation after `.agent/WIKI.md` and before deep source search.

## Sync Rules (Required When Enabled)
- On handoff save, update wiki pages touched by the task and append `log.md`.
- On history append, include `wiki_root` and a short list of wiki pages updated.
- If no wiki updates were needed, write an explicit "No wiki changes required" note in history.
- For `graphify`, regenerate or query the graph only when explicitly useful for the task; do not install always-on assistant hooks, git hooks, or watch mode without explicit user approval.

## Graphify Guardrails (Required When Backend Is `graphify`)
- Generated Graphify output is advisory until verified against source code and tests.
- Exclude secrets, `.env*`, generated files, dependency/vendor folders, build outputs, caches, logs, private client exports, and raw client data before graphing.
- Keep `graphify-out/` local unless the team explicitly decides generated output is safe and useful to commit.
- Commit `.graphifyignore` only when it contains project-safe exclusions.

## Last Sync
| Timestamp (ISO) | Wiki root | Pages updated | Notes |
| --- | --- | --- | --- |
