---
contract_version: 1
artifact_type: wiki_config
status: IN_PROGRESS
depends_on: []
produces:
  - wiki_mode
  - vault_root
  - wiki_root
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

## Paths
- Vault root (absolute): `UNCONFIRMED`
- Repo root (absolute): `UNCONFIRMED`
- Repo name: `UNCONFIRMED`
- Wiki root (absolute): `UNCONFIRMED`
- Wiki index file: `UNCONFIRMED`
- Wiki log file: `UNCONFIRMED`

## Path Convention
- Default wiki root pattern: `{vault_root}/codebases/{repo_name}`
- Default index file: `{wiki_root}/index.md`
- Default log file: `{wiki_root}/log.md`

## Resolution Rules (Required)
1. If `Enabled` is `ON` and `Vault root` is `UNCONFIRMED`, ask one targeted user question for the absolute vault path.
2. After `Vault root` is set, compute and write `Wiki root`, `Wiki index file`, and `Wiki log file`.
3. Mark `status` as `CONFIRMED` after paths are valid and writable.

## Startup Rule (Required When Enabled)
- For full repository review requests, read `.agent/WIKI.md`, then `PLAN/HANDOFF`, then the wiki index, then verify in source code.

## Sync Rules (Required When Enabled)
- On handoff save, update wiki pages touched by the task and append `log.md`.
- On history append, include `wiki_root` and a short list of wiki pages updated.
- If no wiki updates were needed, write an explicit "No wiki changes required" note in history.

## Last Sync
| Timestamp (ISO) | Wiki root | Pages updated | Notes |
| --- | --- | --- | --- |
