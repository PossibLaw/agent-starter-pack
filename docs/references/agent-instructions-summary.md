# Summary Plan: Global & Project Instruction Files

> "If the model weights are not changing mid-week, improvement has to come from the environment you wrap around the agent."

The agent doesn't get smarter between sessions. Your instruction files do. This guide defines what those files are, where they live, what goes in each one, and how they evolve.

Sources reviewed:
- `/Users/salvadorcarranza/Downloads/Untitled document.md` (528 lines)
- `/Users/salvadorcarranza/claude-md-agents-md-reference-guide.md` (539 lines)
- `github.com/Arkya-AI/claude-context-os` (CLAUDE.md, templates, README)

---

## 1) Instruction Hierarchy (No-Conflict Model)

Every instruction has exactly one home. Higher layer wins on conflict.

| Priority | Layer | Scope | Location | Loaded |
|----------|-------|-------|----------|--------|
| 1 | **Global instructions** | All sessions, all projects | `~/.claude/CLAUDE.md` | Always (auto) |
| 2 | **Project instructions** | One repo / workspace | `<project>/CLAUDE.md` | Always when in project (auto) |
| 3 | **Subdirectory instructions** | One area of a project | `<project>/subdir/CLAUDE.md` | Auto within that subtree |
| 4 | **Skills** | On-demand workflow procedures | Plugin skills or `.claude/skills/*/SKILL.md` | When description matches task |
| 5 | **Agents** | Specialized subagent roles | `~/.claude/agents/*.md` or `<project>/.claude/agents/*.md` | When spawned via Task tool |
| 6 | **Commands** | Manual slash-invoked procedures | `.claude/commands/*.md` | On `/invoke` |
| 7 | **State artifacts** | Evolving task/project facts | `.agent/*.md`, `docs/summaries/*.md` | On-demand, referenced |
| 8 | **Reference docs** | Domain knowledge, templates | `docs/*.md`, `templates/*.md` | On-demand |

### Conflict Rule

`Higher layer wins.` If a skill contradicts global or project policy, keep the policy and revise the skill.

### Placement Rule (What Belongs Where)

| Put here | Content type | Examples |
|----------|-------------|----------|
| **Global CLAUDE.md** | Cross-cutting rules used in EVERY session regardless of project | Safety constraints, communication style, context management discipline, change tracking protocol |
| **Project CLAUDE.md** | Facts and rules unique to THIS repo | Commands, stack, code map, local norms, project-specific coding standards |
| **Skills** | Workflow procedures with trigger conditions ("Use when ...") | Brainstorming, TDD, debugging, code review, document processing, session handoff procedures |
| **Agents** | Specialized subagent personas with boundaries | Task planner, test generator, doc-analysis agent, research agent |
| **State artifacts** | Evolving facts, decisions, open questions, handoffs | PLAN.md, CONTEXT.md, TASKS.md, HANDOFF.md, decision records |
| **Reference docs** | Domain knowledge loaded on demand | Architecture docs, testing strategy, templates, domain gotchas |

### What Does NOT Belong Where

| Layer | Exclude |
|-------|---------|
| Global CLAUDE.md | Project-specific commands, code maps, coding standards that vary by repo |
| Project CLAUDE.md | Workflow procedures (those are skills), general prompting philosophy, agent personas |
| Skills | Security policy, non-negotiable constraints (those are global/project instructions) |
| State artifacts | New policy or rules (state files are descriptive, not prescriptive) |

### Cross-Tool Compatibility

`AGENTS.md` is emerging as a cross-tool standard. Multiple tools now read it, making it the best candidate for a shared project instruction file. All tools below use Markdown as the base format.

#### Filename Mapping

| Tool | Global (User-Level) | Project-Level | Cross-Tool Fallback |
|------|---------------------|---------------|---------------------|
| **Claude Code** | `~/.claude/CLAUDE.md`, `~/.claude/rules/*.md` | `./CLAUDE.md`, `./.claude/rules/*.md` | — |
| **Cursor** | Settings UI (plain text) | `.cursor/rules/*.md` | `AGENTS.md` |
| **GitHub Copilot** | VS Code settings | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md` | `AGENTS.md` |
| **Windsurf** | `~/.codeium/windsurf/memories/global_rules.md` | `.windsurf/rules/*.md` | — |
| **Cline** | `~/Documents/Cline/Rules/*.md` | `.clinerules/*.md` | `AGENTS.md`, `.cursor/rules/`, `.windsurf/rules/` |
| **Augment Code** | `~/.augment/rules/*.md` | `.augment/rules/*.md` | `AGENTS.md`, `CLAUDE.md` |
| **Amazon Q** | CLI only (`/context add --global`) | `.amazonq/rules/*.md` | — |
| **Aider** | `~/.aider.conf.yml` | `CONVENTIONS.md` (loaded via `--read` flag) | — |

#### Recommended Multi-Tool Strategy

1. **Write one canonical `AGENTS.md`** at the project root with your stack, code map, commands, and local norms. This is read by Cursor, GitHub Copilot, Cline, and Augment Code.
2. **Add tool-specific files only for features unique to that tool** (e.g., `.claude/rules/*.md` with `paths:` frontmatter for path-scoped rules, `.github/instructions/*.instructions.md` with `applyTo:` globs).
3. **For global instructions**, each tool has its own path — no symlink can unify them. Maintain one source-of-truth file and copy or symlink to each tool's location.
4. **Frontmatter support varies**: Claude Code, Cursor, GitHub Copilot, Windsurf, and Cline support YAML frontmatter for conditional activation. Aider and Amazon Q use plain markdown only.

#### What Goes Where in a Multi-Tool Setup

| Content | Put in `AGENTS.md` (shared) | Put in tool-specific file |
|---------|------------------------------|--------------------------|
| Project description, stack, code map | Yes | No |
| Commands, local norms | Yes | No |
| Path-scoped rules (e.g., "for `*.test.ts` files...") | No | Yes (tool's frontmatter format) |
| Tool-specific features (skills, slash commands) | No | Yes |
| Pointers to detailed docs | Yes | No |

---

## 2) High-Signal Principles

- Start from outcomes, not tools: define the exact deliverable, quality bar, and completion criteria first.
- Keep instructions specific and testable: use exact counts, formats, and pass/fail checks.
- Put executable commands early: list exact runnable commands with flags near the top.
- Separate tool access from workflow guidance: MCP gives capabilities; skills encode how to use those capabilities correctly.
- Constrain scope explicitly: tell the agent where it may work and where it may not.
- Require execution receipts: every run should end with `DONE` or `BLOCKED: <reason>`.
- Prefer updates over duplication: edit existing artifacts rather than creating new copies.
- Add verification gates: source checks, self-review, and human review for high-risk tasks.
- Use strict language: avoid vague terms like "a few", "improve", "better", "roughly".
- Force anti-hallucination behavior: if evidence is missing, mark `UNCONFIRMED` and stop.
- Keep docs lightweight: progressive disclosure and linked references over giant monolithic prompts.
- Treat agent memory as unreliable: maintain plan/context/task files as external state.
- Prefer examples over abstract prose: show one real "good output" snippet whenever possible.
- Build skills eval-first: define scenario tests before writing full skill instructions.
- Only add context the agent doesn't already have: don't explain standard libraries, common patterns, or well-known concepts.
- Write state to disk, not conversation: if it's important, it goes in a file.
- Prefer tables over prose for coordination artifacts: structured data is easier to sort, diff, review, and fix than free-form text.
- Create run logs for multi-step operations: track each change as if it needs to be undone, giving you rollback capability.

---

## 3) File Set, Purpose, and Hierarchy Placement

### Consolidated Directory Structure

```
~/.claude/                              # Global scope
  CLAUDE.md                             # Global instructions (always loaded)
  CHANGELOG.md                         # Global change log
  rules/*.md                           # Global rules (always loaded)
  agents/*.md                          # Global agent definitions

<project>/                              # Project scope
  CLAUDE.md                             # Project instructions (always loaded)
  AGENTS.md                             # Multi-agent orchestration (always loaded)
  .claude/
    CHANGELOG.md                       # Project change log
    rules/*.md                         # Project rules (always loaded)
    skills/*/SKILL.md                  # Auto-discovered skills (on match)
    commands/*.md                      # Slash commands (on /invoke)
    agents/*.md                        # Project agent definitions (on spawn)
  .agent/                              # State artifacts (per-task, evolving)
    PLAN.md                            # Objective, constraints, milestones
    CONTEXT.md                         # Architecture notes, decisions, refs
    TASKS.md                           # Execution checklist with status
    REVIEW.md                          # Code review rubric
    TEST.md                            # Validation matrix
    HANDOFF.md                         # Session handoff
  docs/                                 # Reference docs (on-demand)
    architecture.md
    testing-strategy.md
    domain-gotchas.md
    summaries/                         # Persistent state (decision records, handoffs)
      00-project-brief.md
      decision-NNN-*.md
      handoff-*.md
    archive/                           # Processed originals
  templates/
    claude-templates.md                # Summarization templates
```

### Always-Loaded Files

| File | Layer | Purpose |
|------|-------|---------|
| `~/.claude/CLAUDE.md` | GLOBAL | Communication style, safety, context management rules, change tracking |
| `<project>/CLAUDE.md` | PROJECT | Project description, commands, stack, code map, local norms, pointers to docs |
| `<project>/AGENTS.md` | PROJECT | Multi-agent orchestration, routing rules, boundaries, codebase map, local norms |

### On-Demand Files (loaded when needed)

| File | Layer | Purpose |
|------|-------|---------|
| `docs/*.md` | REFERENCE | Domain knowledge, architecture, testing strategy, gotchas |
| `templates/claude-templates.md` | REFERENCE | Structured summary, handoff, decision record templates |
| `.claude/skills/*/SKILL.md` | SKILL | Auto-discovered workflow procedures |
| `.claude/commands/*.md` | COMMAND | Manually invoked slash commands |
| `~/.claude/agents/*.md` | GLOBAL AGENT | Subagent personas available everywhere |
| `<project>/.claude/agents/*.md` | PROJECT AGENT | Subagent personas for this project |

### Cross-Tool Compatibility (Single-Source Rule)

- Keep one canonical instruction source and mirror/symlink only when tooling requires alternate filenames.
- If multiple tools are used (for example `CLAUDE.md`, `agents.md`, or editor-specific instruction files), update one source first, then propagate.
- Log compatibility-link or mirror changes in the relevant `CHANGELOG.md`.

### Example Directory Structure

```text
project-root/
  CLAUDE.md
  AGENTS.md
  docs/
    architecture.md
    testing-strategy.md
    summaries/
      00-project-brief.md
  templates/
    claude-templates.md
  .claude/
    skills/
      code-review/
        SKILL.md
        TESTS.md
    commands/
      release.md
    agents/
      test-agent.md
  .agent/
    PLAN.md
    CONTEXT.md
    TASKS.md
    REVIEW.md
    TEST.md
    HANDOFF.md
```

### State Artifacts (evolving per-task)

| File | Layer | Purpose |
|------|-------|---------|
| `.agent/PLAN.md` | STATE | Objective, constraints, milestones, acceptance criteria |
| `.agent/CONTEXT.md` | STATE | Architecture notes, key decisions, references, changed files |
| `.agent/TASKS.md` | STATE | Checkbox execution list with status and blockers |
| `.agent/REVIEW.md` | STATE | Code review rubric and defect severity protocol |
| `.agent/TEST.md` | STATE | Required validation matrix, commands, expected outcomes |
| `.agent/HANDOFF.md` | STATE | Session handoff with status, decisions, next actions |
| `docs/summaries/*.md` | STATE | Persistent project brain: source summaries, decision records, analysis outputs |

### Change Tracking Files

| File | Layer | Purpose |
|------|-------|---------|
| `~/.claude/CHANGELOG.md` | GLOBAL | Tracks all changes to global config with rationale |
| `<project>/.claude/CHANGELOG.md` | PROJECT | Tracks changes to project config with rationale |
| `docs/summaries/decision-*.md` | STATE | Individual decision records with rationale and rejected alternatives |

---

## 4) Global CLAUDE.md Blueprint

**Location:** `~/.claude/CLAUDE.md`
**Target size:** Under 100 lines. This competes with every task for context.
**Contains:** Only rules that apply to ALL sessions regardless of project.

### Sections

```markdown
# Global Instructions

## Communication
- [Style preferences that apply everywhere]
- [Output format preferences]

## Safety and Constraints
- [Non-negotiable rules: no secrets, no destructive commands, scope limits]
- [Three-tier boundary model: Always do / Ask first / Never do]

## Context Management
- [Rules for managing context across long sessions]
- [When to write state to disk]
- [When to suggest session splits]

## Change Tracking
- [Protocol for logging changes to config files]
- [Decision record format for significant choices]

## Verification
- [Universal verification policy]
- [Failure and escalation policy]
```

### What Goes Here (from context-os, adapted)

**Context management rules** (lightweight version, not full procedures):
- Never bulk-read multiple large documents into context at once; process sequentially.
- After completing meaningful work, write a summary to disk (state artifact).
- Monitor context usage; proactively suggest session splits when approaching limits.
- CLAUDE.md files are indexes, not encyclopedias. Project context goes in state files and docs.

**Change tracking protocol:**
- When modifying any CLAUDE.md, agents.md, skill, or agent file, log the change to the appropriate CHANGELOG.md with date, what changed, and why.
- When making a significant decision during a task, create a decision record in `docs/summaries/`.

**Verification policy:**
- No completion claim without evidence (test output, diff summary, or explicit limitation).
- If blocked, stop and return `BLOCKED` with root cause, attempted fixes, and next action.

### What Does NOT Go Here

- Project-specific commands, stack info, code maps (→ PROJECT CLAUDE.md)
- Workflow procedures like TDD, debugging, brainstorming (→ SKILLS)
- Session startup sequences, document processing protocols (→ SKILLS)
- Subagent personas and routing (→ AGENTS)
- Evolving project state (→ STATE artifacts)

### Starter Skeleton

```markdown
# Global Instructions

## Communication
- Direct, professional dialogue. No filler.
- Active voice. Lead with outcomes.
- State confidence levels on recommendations.

## Safety
- Never commit secrets or credentials.
- No destructive commands without explicit confirmation.
- If evidence is missing, mark UNCONFIRMED and stop.

## Context Management
- Never bulk-read multiple large documents; process sequentially.
- Write meaningful state to disk after completing work.
- Suggest session splits when context grows large.

## Change Tracking
- Log changes to any instruction file in the appropriate CHANGELOG.md.
- Entry format: date, what changed, why, impact.

## Verification
- No completion claim without evidence.
- If blocked: BLOCKED with root cause and next action.
```

---

## 5) Project CLAUDE.md Blueprint

**Location:** `<project>/CLAUDE.md`
**Target size:** Under 60 lines (~500 tokens). Hard ceiling: 300 lines.
**Contains:** Only facts and rules unique to THIS project.

### The WHAT / WHY / HOW Framework

| Section | Content |
|---------|---------|
| **WHAT** | Tech stack, project structure, codebase organization |
| **WHY** | Project purpose, what different components do |
| **HOW** | Dev workflows, tooling choices, test/build/lint commands |

### Recommended Template

```markdown
# CLAUDE.md

[Project description - 2 lines max]

## Commands
pnpm dev          # Start dev server
pnpm lint:fix     # Auto-fix linting issues
pnpm typecheck    # Verify type safety

Run `pnpm lint:fix && pnpm typecheck` after code changes.

## Stack
- [Framework], [Key Libraries], [Versions]

## Structure
- `app/` - [Purpose]
- `src/` - [Purpose]
- `tests/` - [Purpose]

## Code Map
- Entry point: `src/main.ts`
- Config: `pyproject.toml`, `.env.example`
- `src/api/` - REST endpoints (one file per resource)
- `src/db/` - Database models and migrations
- Tests mirror `src/` structure under `tests/`

## Local Norms
- [Rule + WHY] e.g., "Always run in pixi context - bare Python misses deps"
- [Behavioral correction + WHY] e.g., "Don't modify tests to pass; fix the code instead"

## Further Reading
**IMPORTANT:** Read relevant docs below before starting any task.
- `docs/testing-strategy.md`
- `docs/domain-gotchas.md`
- `docs/architecture.md`
```

### What to Include

1. **Project overview** (2-3 lines): what it does, key technologies.
2. **Executable commands** (3-5 lines): real commands with actual flags. Place early.
3. **Code map** (5-10 lines): entry points, high-signal files, directory roles, naming conventions. Reduces agent search time dramatically.
4. **Local norms with reasoning**: things you find yourself correcting repeatedly. Once documented, these eliminate repeated correction cycles.
5. **Pointers to detailed docs** with an IMPORTANT directive to read them before tasks.

### What NOT to Include

- Code style rules that linters handle (let ESLint/Prettier/Biome do it).
- Auto-generated content (hand-craft every line).
- Task-specific instructions (put in state artifacts or docs).
- Historical context / war stories (put in separate docs).
- Workflow procedures (those are skills).
- Communication preferences (those are in global CLAUDE.md).
- Content that tools can already verify (build systems, type checkers provide backpressure).
- Time-sensitive information (document current method; put deprecated approaches in collapsible sections).

### Starter Skeleton

```markdown
# CLAUDE.md

[2-line project description]

## Commands
[command]    # [purpose]
[command]    # [purpose]

## Stack
- [Framework], [Libraries], [Versions]

## Code Map
- Entry: `src/main.ts`
- Config: `pyproject.toml`
- [directory] - [purpose]

## Local Norms
- [Rule + WHY]

## Further Reading
**IMPORTANT:** Read before starting tasks.
- `docs/architecture.md`
- `docs/testing-strategy.md`
```

---

## 6) AGENTS.md Blueprint

**Location:** `<project>/AGENTS.md`
**Purpose:** Multi-agent orchestration, routing, and repository memory.
**Two jobs:** Fast navigation and durable local norms.

### Recommended Sections

- **Codebase map**: entry points, directory roles, config wiring, test locations.
- **Agent roles**: explicit responsibilities and boundaries per agent type.
- **Routing rules**: `If task is X, assign to role Y; if uncertain, escalate once with targeted question.`
- **Handoff contract**: each handoff includes objective, inputs, outputs, assumptions, risks, and next owner.
- **Boundary rules** (three-tier model): `Always do`, `Ask first`, `Never do`.
- **Boundary objects**: standard artifacts passed between agents (plan table, diff summary, test report, risk log).
- **Shared status format**: `IN_PROGRESS`, `DONE`, `BLOCKED`, `UNCONFIRMED`.
- **Local norms**: repo-specific rules learned from tooling and past corrections.
- **Self-correction**: instructions for how norms and code map are updated over time.

### Frontmatter Example

```yaml
---
name: test-agent
description: Writes and updates tests for the repository without changing application logic.
---
```

### Recommended Agent Types

| Agent | Role | Boundary |
|-------|------|----------|
| `@docs-agent` | Reads code, writes docs | Write to `docs/` only |
| `@test-agent` | Writes tests | Cannot remove failing tests without auth |
| `@lint-agent` | Fixes style | Never changes logic |
| `@api-agent` | Creates endpoints | Asks before schema changes |
| `@security-agent` | Analyzes vulnerabilities | Read-only |

### Coordination Limits

- Cap fan-out and require aggregation steps to avoid "swarm chaos."
- A human tops out at <10 direct reports; 100 subagents is too many for one orchestrator. Use middle-management agents.
- Design for bounded rationality: agents have limited context.

### Self-Correction Rules

- If exploration shows the code map is stale, update it during the same task.
- If the user gives a repo workflow correction, persist it into `Local norms`.
- Keep updates lightweight: prefer on-demand updates from mismatches; optional scheduled refresh.

### AGENTS.md Bootstrap Process

- Use search plus targeted file reads; do not read every file by default.
- Prioritize high-signal files first: `README`, `pyproject.toml`, `package.json`, `Makefile`, `.github/workflows`, top-level `src`/`app`.
- Keep generated `AGENTS.md` concise and navigation-focused.

### Starter Skeleton

```markdown
# AGENTS.md

## Codebase Map
[entry points, directory roles, config wiring]

## Roles
[agent roles with boundaries]

## Routing Rules
[If task X → role Y]

## Handoff Contract
[objective, inputs, outputs, assumptions, risks, next owner]

## Boundary Rules
- Always do: [list]
- Ask first: [list]
- Never do: [list]

## Local Norms
[repo-specific rules learned from corrections]
```

---

## 7) Context Management and Session Discipline

**Hierarchy placement:** Principles go in GLOBAL CLAUDE.md (lightweight). Detailed procedures go in SKILLS or REFERENCE docs.

### Core Problem (from context-os)

LLM default summarization loses five specific categories:
1. **Precise numbers** get rounded or dropped.
2. **Conditional logic** (IF/BUT/EXCEPT) collapses to simple statements.
3. **Decision rationale** (WHY) evaporates — only WHAT survives.
4. **Cross-document relationships** flatten to single statements.
5. **Open questions** get silently resolved as settled.

The fix is structured templates with explicit fields that mechanically prevent these five failure modes. Don't fight compaction — design around it.

### Rules (→ GLOBAL CLAUDE.md, lightweight)

1. **Never bulk-read documents**: process one at a time, summarize, move on.
2. **Write state to disk, not conversation**: if it's important, it goes in a file.
3. **Compact manually at logical breakpoints**: write state to file first, then compact.
4. **One concern per session**: research OR writing OR review, not all three when context gets large.
5. **CLAUDE.md is an index, not an encyclopedia**: project context goes in summary files and docs.
6. **Monitor context continuously**: suggest session splits proactively when approaching limits.

### Session Splitting (→ SKILL or REFERENCE doc, not in CLAUDE.md)

When to split:
- Context usage exceeds 60%.
- Switching from one phase of work to another.
- Conversation has exceeded ~20 substantive exchanges.
- About to start a task requiring reading 3+ large files.

How to split:
1. Write a structured handoff to `docs/summaries/handoff-[date]-[topic].md`.
2. Tell the user a fresh session is recommended.
3. Next session picks up by reading the handoff file.

### Document Processing Protocol (→ SKILL or REFERENCE doc)

For 1-3 short documents (< 2K words each): read sequentially, write source summary after each.
For 4+ documents or any > 2K words:
1. List all with sizes, let user prioritize.
2. Process each individually: read → extract to summary → release from context.
3. After all processed, work from summaries only.
4. Cross-reference summaries for contradictions.

### Archive Protocol (→ PROJECT-level convention)

- After creating a source summary, move raw file to `docs/archive/`.
- Never re-read from archive unless user explicitly says to.
- Session handoffs: only keep the latest; archive previous ones.
- Decision records persist permanently.
- If `docs/summaries/` exceeds 15 files, consolidate older ones into a project digest.

---

## 8) Structured Summarization Templates

**Hierarchy placement:** Templates live in `templates/claude-templates.md` as REFERENCE docs. Loaded on demand, never at session start.

### Template 1: Source Document Summary → `docs/summaries/source-[filename].md`

Fields: processed date, source path, document type, confidence level.
Sections: Exact Numbers & Metrics, Key Facts (Confirmed), Requirements & Constraints (IF/THEN/BUT/EXCEPT format), Decisions Referenced (with rationale and rejected alternatives), Relationships to Other Documents, Open Questions & Ambiguities (UNCLEAR/ASSUMED/MISSING markers), Verbatim Quotes Worth Preserving.

### Template 2: Analysis / Research Summary → `docs/summaries/analysis-[topic].md`

Fields: date, analysis type, sources, confidence with reasoning.
Sections: Core Finding (one sentence), Evidence Base (table with exact values and sources), Detailed Findings (WHAT/SO WHAT/EVIDENCE/CONFIDENCE per finding), Conditional Conclusions (IF/THEN format), What This Analysis Does NOT Cover, Recommended Next Steps.

### Template 3: Decision Record → `docs/summaries/decision-[number]-[topic].md`

Fields: Decision ID (DR-NNN), date, status (CONFIRMED/PROVISIONAL/REQUIRES_VALIDATION).
Sections: Decision (one sentence), Context, Rationale (CHOSE X BECAUSE / REJECTED Y BECAUSE), Quantified Impact, Conditions & Constraints (VALID IF/REVISIT IF/DEPENDS ON), Downstream Effects.

### Template 4: Session Handoff → `docs/summaries/handoff-[date]-[topic].md`

Fields: date, session focus, context usage at handoff.
Sections: What Was Accomplished (with file paths), Exact State of Work in Progress, Decisions Made (referencing DRs), Key Numbers Generated, Conditional Logic Established, Files Created or Modified (table), What the NEXT Session Should Do (ordered), Open Questions Requiring User Input, Assumptions That Need Validation, What NOT to Re-Read.

### Template 5: Project Brief → `docs/summaries/00-project-brief.md`

Fields: project name, created/updated dates.
Sections: Client info, Engagement details, Input Documents (table with processed status), Success Criteria, Known Constraints, Project Phase Tracker (table).

### Subagent Output Contracts (→ AGENT definitions or REFERENCE doc)

Subagents must return structured fields, not free-form prose. Three contracts:

- **Document Analysis Contract**: SOURCE, TYPE, CONFIDENCE, NUMBERS, REQUIREMENTS, DECISIONS_REFERENCED, CONTRADICTIONS, OPEN, QUOTES.
- **Research/Analysis Contract**: QUERY, SOURCES, CONFIDENCE + BECAUSE, CORE_FINDING, EVIDENCE, CONCLUSIONS (IF/THEN), GAPS, NEXT_STEPS.
- **Review/QA Contract**: REVIEWED, AGAINST, PASS, ISSUES (severity/item/location/fix), MISSING, INCONSISTENCIES, STRENGTHS.

---

## 9) Change Tracking Protocol

**Hierarchy placement:** The protocol rule goes in GLOBAL CLAUDE.md. The changelog files live at their respective scopes.

### Purpose

Track WHY configuration changed, not just WHAT changed. Enable future sessions to understand the reasoning behind the current state. Prevent conflicting changes across global and project layers.

### Changelog Locations

| Scope | File | Tracks changes to |
|-------|------|-------------------|
| Global | `~/.claude/CHANGELOG.md` | `~/.claude/CLAUDE.md`, global agents, global settings |
| Project | `<project>/.claude/CHANGELOG.md` | Project `CLAUDE.md`, `AGENTS.md`, project agents, project skills |

### Changelog Entry Format

```markdown
## [YYYY-MM-DD] - [Brief title]

**Changed:** [What file/section was modified]
**Reason:** [Why this change was made — the specific problem or improvement]
**Impact:** [What other files or behaviors this affects]
**Decided:** [CONFIRMED / PROVISIONAL — and who decided]
```

### When to Log

- Any edit to a CLAUDE.md file (global or project).
- Any edit to an AGENTS.md file.
- Adding, removing, or modifying a skill or agent definition.
- Adding or changing a local norm.
- Changing coordination rules, routing rules, or boundary definitions.
- NOT: edits to state artifacts (PLAN.md, TASKS.md, handoffs) — those are inherently temporal.

### Operational Traceability

- Keep a per-task run log in state artifacts so each change can be traced and, if needed, reversed.
- Prefer table-based run logs over raw prose for sorting and quick audits.
- Minimum columns: `timestamp`, `action`, `files touched`, `validation command`, `result`.

### Decision Records for Significant Choices

For major configuration decisions (e.g., "moved TDD workflow from CLAUDE.md to a skill"), create a full decision record using Template 3 in `docs/summaries/decision-NNN-[topic].md`. Reference it from the changelog entry.

### Cross-Layer Conflict Prevention

Before making a change, check:
1. Does this rule already exist at a higher layer? If so, don't duplicate it.
2. Does this change contradict something at a higher layer? If so, the higher layer wins — adjust the lower layer.
3. Is this a workflow procedure? If so, it belongs in a skill, not in CLAUDE.md.
4. Is this evolving project state? If so, it belongs in a state artifact, not in instructions.

---

## 10) Progressive Disclosure Architecture

### Three-Layer System

```
Layer 1: CLAUDE.md (~500 tokens)
  - Always loaded automatically
  - Project overview, essential commands, stack
  - Pointers to specialized docs

Layer 2: docs/ folder (200-500 tokens per file)
  - Loaded on-demand when relevant
  - Domain-specific gotchas, testing strategies
  - Knowledge accumulated through corrections

Layer 3: skills/ and agents/ (300-800 tokens each)
  - Specialized domain expertise
  - Loaded via Task tool or skill trigger
  - Can fetch live documentation
```

### When to Use What

| Use Case | Tool | Why |
|----------|------|-----|
| Always-loaded project rules | CLAUDE.md | Auto-loaded, git-shared, persistent |
| Manual workflows (`/trigger`) | Slash command | Terminal discoverable, argument-aware |
| Research + doc fetching | Subagent | Separate context window, distilled output |
| Auto-applied rich workflows | Skill | Auto-discovered, supporting files |
| Heavy document processing | Subagent | Keeps source content out of main context |
| Writing deliverables | Main agent | Needs full decision-making context |
| Review and QA | Subagent | Fresh perspective, no bias from writing |

---

## 11) Skill Authoring Standard

### Structure

```
skill-name/
  SKILL.md          # Required: instructions + metadata
  scripts/          # Optional: executable code
  references/       # Optional: documentation (one level deep)
  assets/           # Optional: templates, resources
```

### How Skills Load (Progressive Disclosure)

1. **Discovery** (~100 tokens): Only name + description loaded at startup from all skills.
2. **Activation** (< 5000 tokens): Full SKILL.md body loaded when task matches description.
3. **Execution** (as needed): Referenced files and scripts loaded only when required.

### SKILL.md Frontmatter

Required fields:
```yaml
---
name: processing-pdfs
description: >
  Extracts text and tables from PDF files, fills forms, merges documents.
  Use when working with PDF files or when the user mentions PDFs, forms,
  or document extraction.
---
```

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | Max 64 chars. Lowercase + hyphens. Must match parent directory name. |
| `description` | Yes | Max 1024 chars. Third person. What + when to use. |
| `license` | No | License name or reference |
| `compatibility` | No | Max 500 chars. Environment requirements |
| `allowed-tools` | No | Space-delimited pre-approved tools |
| `metadata` | No | Arbitrary key-value pairs |

### Key Rules

- **Naming**: Use gerund form (verb + -ing): `processing-pdfs`, `analyzing-spreadsheets`. Avoid generic names like `helper`, `utils`, `tools`.
- **Descriptions**: Always third person ("Processes files" not "I help you process"). When-to-use conditions MUST be in the description, not buried in the body.
- **Size**: Keep SKILL.md body under 500 lines. Move deep details to `references/`.
- **References**: One level deep. Name descriptively. Over 100 lines gets a TOC.
- **Body order**: Quick start, When to use what (decision matrix), Common mistakes, References.
- **Anti-patterns**: Include explicit "Don't do this / Do this" blocks.
- **Freedom levels**: Match instruction specificity to fragility. Low freedom (exact scripts) for fragile operations. High freedom (text guidance) when multiple approaches are valid.
- **Defaults over options**: "Use pdfplumber for text extraction. For scanned PDFs, use pdf2image with pytesseract." Don't present 5 choices.
- **Feedback loops**: For quality-critical tasks, build validate-fix-repeat loops.
- **Plan-validate-execute**: For high-stakes operations, require verifiable intermediate outputs.
- **Copyable checklists**: For multi-step workflows, provide a checklist the agent copies and tracks mechanically:

```markdown
## Workflow: [name]

Copy this checklist and track progress:

Task Progress:
- [ ] Step 1: Analyze input (run `scripts/analyze.py`)
- [ ] Step 2: Create mapping (edit `config/mapping.json`)
- [ ] Step 3: Validate mapping (run `scripts/validate.py`)
- [ ] Step 4: Execute (run `scripts/execute.py`)
- [ ] Step 5: Verify output (run `scripts/verify.py`)
```

This gives the agent a concrete tracking mechanism rather than relying on memory.

### Skill Distribution (Optional)

Use plugin-style packaging when sharing skills across teams or repositories:

```text
my-plugin/
  .claude-plugin/
    plugin.json       # Manifest: name, version, description, dependencies
  skills/
    review/
      SKILL.md
      TESTS.md
```

Namespacing prevents collisions: `/my-plugin:review` won't conflict with another team's `/review`. When installing shared skills, always use the namespace prefix to avoid ambiguity.

### Eval-Driven Skill Development Loop

1. Define success in `TESTS.md` using concrete scenarios and expected outcomes.
2. Build or update `SKILL.md` to satisfy those scenarios.
3. Test skill behavior against the scenarios.
4. Move deep examples and edge cases into `references/`.
5. Iterate until outputs are correct and consistent.

### TESTS.md Scenario Pattern

```yaml
scenarios:
  - name: "Send welcome email"
    prompt: "Send a welcome email to a new user"
    expected: "Uses send() with proper template"
  - name: "Handle bounce"
    prompt: "What happens when an email bounces?"
    expected: "Explains webhook setup and retry logic"
```

### Skill Quality Checklist

- [ ] Description is specific, third-person, includes what + when
- [ ] SKILL.md body under 500 lines
- [ ] Additional details in separate reference files
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] File references one level deep
- [ ] Workflows have clear steps with checklists
- [ ] Scripts handle errors explicitly
- [ ] Validation/feedback loops for critical operations

---

## 12) Supporting Instruction Files (State Artifacts)

All state artifacts are descriptive (recording facts) not prescriptive (creating policy).

### PLAN.md (→ STATE)

- Problem statement.
- Scope and non-scope.
- Keep plan lines concise; optimize for scan speed over prose quality.
- Assumptions and top risks.
- Unresolved questions that may block implementation.
- Milestones with acceptance checks.
- Exit criteria.

### CONTEXT.md (→ STATE)

- Architecture notes and key decisions.
- Relevant files and references.
- Changed files log.

### TASKS.md (→ STATE)

- Checkbox execution list with status and blockers.
- Dependencies between tasks clearly marked.

### REVIEW.md (→ STATE)

- Review order: correctness, regressions, security/privacy, maintainability, tests.
- Severity levels: `S0` critical, `S1` major, `S2` minor.
- Required review outputs: issue, impact, file reference, reproduction/evidence, proposed fix.
- Mandatory self-review pass before handing back.

### TEST.md (→ STATE)

- Required checks by change type: lint, unit, integration, typecheck, build, smoke.
- Command list and expected pass criteria.
- Failure handling: include failing command, exact error, and mitigation attempt.
- Completion rule: no "done" without test evidence or explicit waiver.

### HANDOFF.md (→ STATE)

- Status, decisions made (with rationale and rejected alternatives), exact values/constraints.
- Open questions, next actions, do-not-reread pointers.
- Use explicit markers: `CONFIRMED`, `OPEN`, `ASSUMED`, and conditional rules (`IF/THEN/BUT/EXCEPT`).

### Git Workflow Contract (→ PROJECT CLAUDE.md or AGENTS.md)

- Branching expectations.
- Commit expectations (message format, scope per commit).
- PR expectations (summary, test evidence, risk notes).
- Never commit secrets.

---

## 13) Prompting & Instruction Writing Principles

### Instruction Language Rules

- Write in plain strict language: "create six questions" not "create a few questions."
- Don't let it make things up: use `UNCONFIRMED` markers and verification gates.
- Provide alternatives, not prohibitions: "Do Y instead of X because Z" beats "Never do X."
- Explain reasoning: rules with "why" are followed better than bare directives.
- Demand receipts: `DONE` or `BLOCKED + reason` so you know what happened.
- Use consistent terminology: pick one term per concept and stick with it everywhere.
- Write in third person for anything injected into system prompts.

### Risk-Based Instruction Depth

| Risk Level | Strategy | Components |
|------------|----------|------------|
| Low (brainstorming) | Simple structure | Role + Goal |
| Medium (work tasks) | Add reasoning controls | Context + Constraints + Evidence |
| High (legal, financial) | Full verification | Verification + Human review + Citations |

### Action-Oriented Writing

- Bias toward action: remove "plan" or "outline" that cause premature stopping.
- Batch requests: ask for multiple things simultaneously.
- Persist until complete: "Deliver finished work, not just recommendations."
- Be ruthlessly specific: exact format, exact style, exact structure.

### Three Things Missing When Output Frustrates

1. A specific **quality threshold** ("100% fidelity" or "maximally useful").
2. A concrete **structural example** ("here's how to format it").
3. Explicit **verification criteria** ("spell out every acronym").

### Prompt Technique Selection

Use this matrix when authoring skills or complex instructions to choose the right reasoning approach.

| Technique | Use When | Example Application |
|-----------|----------|---------------------|
| **Chain-of-Thought** | Single correct path, step-by-step reasoning needed | Debugging a specific error, calculating dependencies |
| **Tree-of-Thought** | Multiple valid approaches, need to explore and compare | Architecture decisions, choosing between libraries |
| **Prompt Chaining** | Multi-step pipeline where output of one step feeds the next | Extract data → validate → transform → load |
| **Reflexion** | Quality-critical output, agent should critique and revise its own work | Code review, document drafting, test writing |
| **ReAct** | Task requires alternating between reasoning and action | Research tasks, debugging with tool use |
| **RAG** | Answer depends on retrieved external context | Documentation lookup, codebase exploration |
| **Meta Prompting** | Prompt itself needs refinement before execution | Complex instruction authoring, skill writing |
| **Generate Knowledge** | Agent needs to explain a framework before applying it | Unfamiliar domain, first-time integration |

### 10-Part Prompt Structure

When composing complex instructions (skills, agent definitions, detailed task prompts), use this structure as a checklist. Not every prompt needs all 10 parts — match depth to risk level above.

1. **Task context** — what the agent is working on and why
2. **Tone context** — how to communicate (professional, concise, etc.)
3. **Background data** — relevant documents, schemas, prior decisions
4. **Detailed task description and rules** — specific requirements and constraints
5. **Examples of desired output** — concrete "good output" specimens
6. **Conversation history** — relevant prior context (for multi-turn)
7. **Immediate task** — the specific action to take now
8. **Reasoning instruction** — "Think step by step" or technique selection from matrix above
9. **Output format** — exact structure, fields, and format requirements
10. **Prefilled response** — guide the start of output to set the right pattern

---

## 14) Reusable Copy/Paste Clauses

Drop these into instruction files as-is. Principles behind them are defined in sections 2 and 4.

- `Work only in <path> and its subpaths.`
- `If a required fact is missing, output UNCONFIRMED instead of guessing.`
- `Do not create duplicate files when an existing artifact can be updated.`
- `Return DONE only after all acceptance checks pass; otherwise return BLOCKED with reason.`
- `List 3 assumptions and 2 biggest risks before implementation.`
- `For high-risk domains (legal/financial/medical/security), require source verification and human review.`
- `Prefer finished deliverables over outlines unless an outline is explicitly requested.`
- `Description format: "Use when [trigger conditions] with [tool/API] for [outcome]".`
- `If a skill conflicts with global/project policy, follow policy and mark the skill for correction.`
- `State what changed, why, where, and how validated.`
- `No completion claim without evidence (test output, diff summary, or explicit limitation).`

---

## 15) Anti-Patterns Checklist

| Anti-Pattern | Fix |
|---|---|
| Bloated CLAUDE.md (300+ lines) | Progressive disclosure: concise root + detailed docs |
| Auto-generated CLAUDE.md | Hand-craft every line |
| Style rules in CLAUDE.md | Use linters and formatters |
| Workflow procedures in CLAUDE.md | Move to skills |
| Global rules duplicated in project files | Keep in global only; project inherits |
| Project-specific rules in global file | Move to project CLAUDE.md |
| Vague agent descriptions | Specific persona + boundaries + examples |
| Skills without when-to-use in description | Put trigger conditions in the description field |
| Skill description in first/second person | Always use third person |
| No boundaries defined | Use always-do / ask-first / never-do tiers |
| Pasting code snippets | Use `file:path:line` references instead |
| "Never do X" without alternative | "Do Y instead of X because Z" |
| Skipping planning | Plan > Execute > Test > Commit loop |
| No self-review step | Have the agent review its own output before proceeding |
| Raw text between agents | Use structured boundary objects / output contracts |
| Too many subagents on one orchestrator | Add middle-management layer |
| Offering too many tool/library options | Provide one default with escape hatch |
| Deeply nested file references | Keep references one level deep from SKILL.md |
| Writing docs before evaluations | Build 3 eval scenarios first, then write minimal docs |
| Time-sensitive instructions | Use "current method" + collapsible "old patterns" |
| Inconsistent terminology | Pick one term per concept and use it everywhere |
| Completion claims without proofs | Require test output, diff summary, or explicit limitation |
| State files becoming policy | State artifacts are descriptive only, never prescriptive |
| Decisions stored only in chat history | Write to decision records that persist across sessions |
| Config changes without rationale | Log every change to CHANGELOG.md with reason |
| Explaining things the agent already knows | Only add context unique to your project |
| Monolithic SKILL.md files | Core + references structure |
| Missing "Common mistakes" in skills | Prevents repeated bad patterns |
| Massive instruction files | Modular references over giant monolithic prompts |

---

## 16) Additional Starter Skeletons

Skeletons for Global CLAUDE.md, Project CLAUDE.md, and AGENTS.md are located in their respective blueprint sections (4, 5, and 6).

### State Artifacts

```markdown
# .agent/PLAN.md
## Goal
## Constraints
## Risks and Assumptions
## Milestones
## Acceptance Criteria
```

```markdown
# .agent/HANDOFF.md
## Status
## Decisions (with rationale and rejected alternatives)
## Exact Values / Constraints
## Open Questions
## Next Action
## Do-Not-Reread
```

### CHANGELOG.md

```markdown
# Changelog

## [YYYY-MM-DD] - Initial setup
**Changed:** Created CLAUDE.md
**Reason:** [Why this configuration was chosen]
**Impact:** [What behaviors this establishes]
**Decided:** CONFIRMED
```

### Skill Skeleton

```markdown
# skills/my-tool/SKILL.md
---
name: my-tool-skill
description: >
  Use when integrating with MyTool for authentication flows.
  Handles OAuth setup, token refresh, and error recovery.
---
## Quick start
## When to use what
## Common mistakes
## References
```

```yaml
# skills/my-tool/TESTS.md
scenarios:
  - name: "Happy path"
    prompt: "..."
    expected: "..."
```

---

## 17) Iteration Loops

### Loop 1: Better Agent Files (from observed failures)

1. Start with one focused agent and one concrete task.
2. Run it against a real failing or incomplete task.
3. Observe mistakes (missing commands, unclear boundaries, weak examples).
4. Tighten instructions with explicit commands, examples, and boundaries.
5. Repeat; grow the file from observed failure modes rather than big upfront design.

### Loop 2: Durable Improvement (from operational feedback)

1. Observe a mismatch between expected and actual agent behavior.
2. Convert the correction into a concrete norm in the appropriate file (CLAUDE.md, AGENTS.md, or a skill).
3. Log the change in the appropriate CHANGELOG.md with rationale.
4. Re-run the task and verify the correction removed repeated friction.
5. Keep the correction if it generalizes; remove it if it was one-off noise.

### Loop 3: Self-Correction

See section 6 (AGENTS.md Blueprint → Self-Correction Rules) for the specific rules. The key insight: on-demand updates from observed mismatches create more responsive loops than scheduled refreshes.

### Loop 4: Agent A / Agent B Pattern (for skills)

1. Complete a task with Agent A using normal prompting. Notice what context you repeatedly provide.
2. Ask Agent A to capture that pattern as a skill.
3. Review for conciseness: remove explanations of things the agent already knows.
4. Test with Agent B (fresh instance with the skill loaded) on real tasks.
5. Observe Agent B's behavior. Where does it struggle?
6. Return to Agent A to fix the skill. Repeat.
