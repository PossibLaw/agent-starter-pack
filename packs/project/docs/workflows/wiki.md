# Wiki Mode (Optional)

Use this mode when repo orientation costs too much time each session.
Default is `OFF`.

## Purpose

A wiki is a persistent, LLM-maintained knowledge layer that accelerates context loading.
It is not a replacement for source code verification.

## Trust Order (Required)

1. Source code, tests, and runtime behavior
2. Active state artifacts (`PLAN.md`, `TEST.md`, `REVIEW.md`, `HANDOFF.md`)
3. Wiki pages and summaries

If wiki content conflicts with code, treat wiki content as stale and update it.

## Setup

You may keep the wiki:
- Inside the repo (example: `docs/wiki/`)
- In an external Obsidian vault on local disk

Recommended core files:
- `index.md` (topic/page index)
- `log.md` (append-only operations log)
- `pages/*` (entity/concept/project pages)

## Startup Flow (Wiki Enabled)

1. Read active `HANDOFF.md` and `PLAN.md`.
2. Read `wiki/index.md` (or vault index) and 1-3 relevant wiki pages.
3. Verify wiki claims against live code before editing files.
4. Execute task and checks.
5. Update wiki pages and append `log.md` with what changed.

## Source Ingest Flow

When new source material is added:
1. Add raw source reference to `log.md`.
2. Update relevant wiki pages with summaries and cross-links.
3. Tag uncertain claims as `UNCONFIRMED`.
4. Record exact file path and timestamp for each new claim.

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
