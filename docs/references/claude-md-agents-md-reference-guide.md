# Reference Guide: Building CLAUDE.md, agents.md & Instruction Files

A distilled guide drawn from community best practices, blog posts, and practitioner insights.

---

## Part 1: CLAUDE.md Fundamentals

### What CLAUDE.md Is
The single highest-leverage customization point for Claude Code. It is automatically injected into every conversation. Poor guidance here compounds errors across research, planning, and implementation.

### Golden Rule: Keep It Short
- Target **under 60 lines (~500 tokens)** for the root file
- Hard ceiling: **300 lines** before you're actively hurting performance
- Frontier LLMs reliably follow ~150-200 instructions; Claude Code's system prompt already uses ~50 of those
- Every token competes with the actual task context

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
- [Rule you keep repeating + WHY] e.g., "Always run in pixi context - bare Python misses deps"
- [Behavioral correction + WHY] e.g., "Don't modify tests to pass; fix the code instead"

## Further Reading
**IMPORTANT:** Read relevant docs below before starting any task.
- `docs/testing-strategy.md`
- `docs/domain-gotchas.md`
- `docs/architecture.md`
```

### What to Include
1. **Project overview** (2-3 lines): what it does, key technologies
2. **Executable commands** (3-5 lines): real commands with actual flags, not abstract tool names
3. **Code map** (5-10 lines): entry points, high-signal files (README, pyproject.toml, package.json, Makefile, config files), directory roles, and naming conventions. A good code map reduces agent search time dramatically (practitioners report 40s down to 2s). Focus on navigation, not exhaustive listing.
4. **Local norms** with reasoning: the things you find yourself saying out loud repeatedly ("Run Python in the pixi context", "Don't modify tests to make them pass"). Once documented, these eliminate repeated correction cycles.
5. **Pointers to detailed docs** with an IMPORTANT directive to read them before tasks

### The "Claude Is Already Smart" Principle
The context window is a shared resource. Before adding anything, ask:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

Only add context Claude doesn't already have. Don't explain what PDFs are, how libraries work, or what REST means. Focus on what's unique to *your* project.

### What NOT to Include
- **Code style rules** - Let ESLint, Prettier, Biome handle this. LLMs are expensive linters.
- **Auto-generated content** - Never use `/init`. Hand-craft every line.
- **Task-specific instructions** - Database schemas, one-off procedures, anything not universal
- **Historical context / war stories** - Put in separate docs
- **Extensive edge cases** - Move to domain-specific docs
- **Content that tools can verify** - Build systems, type checkers, linters provide "backpressure" already
- **Time-sensitive information** - Avoid "before August 2025 use X, after use Y". Instead, document the current method and put deprecated approaches in a collapsible "Old patterns" section

---

## Part 2: Progressive Disclosure Architecture

### Three-Layer System

```
Layer 1: CLAUDE.md (~500 tokens)
  - Always loaded automatically
  - Project overview, essential commands, stack
  - Pointers to specialized docs

Layer 2: /docs folder (200-500 tokens per file)
  - Loaded on-demand when relevant
  - Domain-specific gotchas, testing strategies
  - Knowledge accumulated through /learn pattern

Layer 3: .claude/agents/ or .claude/skills/ (300-800 tokens each)
  - Specialized domain expertise
  - Loaded via Task tool or skill trigger
  - Can fetch live documentation
```

### Example Directory Structure
```
project-root/
  CLAUDE.md                          # Layer 1: concise, always-loaded
  docs/
    testing-strategy.md              # Layer 2: on-demand
    domain-gotchas.md
    architecture.md
    database-schema.md
  .claude/
    skills/
      code-review/
        SKILL.md                     # Layer 3: auto-discovered
        PATTERNS.md
      test-writer/
        SKILL.md
    commands/
      deploy.md                      # Slash commands
      db-migrate.md
```

### When to Use What

| Use Case | Tool | Why |
|---|---|---|
| Always-loaded project rules | CLAUDE.md | Auto-loaded, git-shared, persistent |
| Manual workflows (`/trigger`) | Slash command | Terminal discoverable, argument-aware |
| Research + doc fetching | Subagent | Separate context window, distilled output |
| Auto-applied rich workflows | Skill | Auto-discovered, supporting files |

---

## Part 3: agents.md / Copilot Instructions

### Six Essential Sections
1. **Commands** - Place early. Provide complete runnable commands with flags.
2. **Testing practices** - How tests should be written and run.
3. **Project structure** - Directories and their purposes.
4. **Code style** - Brief, only what linters don't cover.
5. **Git workflow** - Branching, commit message format, PR process.
6. **Boundaries** - What the agent must/should/must-not do.

### Three-Tier Boundary Model
- **Always do**: Clear positive directives
- **Ask first**: Actions requiring human approval
- **Never do**: Prohibited actions (e.g., commit secrets, modify production config)

### Persona Definition
Bad: "You are a helpful coding assistant."
Good: "You are a test engineer who writes tests for React components, follows the patterns in `tests/examples/`, and never modifies source code."

Expand with: technical specializations, target audience, expected output format.

### Recommended Agent Types
| Agent | Role | Boundary |
|-------|------|----------|
| `@docs-agent` | Reads code, writes docs | Write to `docs/` only |
| `@test-agent` | Writes tests | Cannot remove failing tests without auth |
| `@lint-agent` | Fixes style | Never changes logic |
| `@api-agent` | Creates endpoints | Asks before schema changes |
| `@security-agent` | Analyzes vulnerabilities | Read-only |

### Cross-Tool Compatibility
Symlink `CLAUDE.md` to `agents.md` so VS Code Copilot, Cursor, and Claude Code all read the same config.

---

## Part 4: Plan, Context & Task Files

### The Three Non-Negotiable Dev Docs
For any non-trivial task, maintain three files:

1. **Plan document** - What you're building, approach, architecture decisions
2. **Context document** - Key decisions made, relevant files, constraints
3. **Tasks checklist** - What's done, what's next, blockers

Update these as you go. Claude has "extreme amnesia" and loses track across context resets. These docs keep it on rails.

### Plan Document Best Practices
- Prioritize brevity: sacrifice grammar for concision
- Surface uncertainties: list unresolved questions that need answers
- Use a plan-first workflow: Plan > Execute > Test > Commit > Repeat
- Plans prevent hallucinations; skipping them leads to fighting misunderstandings

### Self-Review Pattern
Before moving forward, have Claude review what it just created. This catches critical errors, missing implementations, inconsistent code, and security flaws.

---

## Part 5: Skills Design

### Skill Structure
```
skill-name/
  SKILL.md          # Required: instructions + metadata
  scripts/          # Optional: executable code
  references/       # Optional: documentation
  assets/           # Optional: templates, resources
```

### How Skills Load (Progressive Disclosure)
1. **Discovery** (~100 tokens): At startup, only name + description from all skills are loaded
2. **Activation** (< 5000 tokens recommended): Full SKILL.md body loaded when task matches description
3. **Execution** (as needed): Referenced files and scripts loaded only when required

Keep SKILL.md body **under 500 lines**. Move detailed reference material to separate files.

### SKILL.md Frontmatter

Required fields:
```yaml
---
name: processing-pdfs
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
```

Optional fields:
```yaml
license: Apache-2.0
compatibility: Requires git, docker, jq
allowed-tools: Bash(git:*) Read
metadata:
  author: my-org
  version: "1.0"
```

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | Max 64 chars. Lowercase + hyphens only. Must match parent directory name. |
| `description` | Yes | Max 1024 chars. What it does + when to use it. |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | Max 500 chars. Environment requirements |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |
| `metadata` | No | Arbitrary key-value pairs |

### Naming Conventions
Use **gerund form** (verb + -ing) for skill names:
- Good: `processing-pdfs`, `analyzing-spreadsheets`, `testing-code`
- Acceptable: `pdf-processing`, `process-pdfs`
- Bad: `helper`, `utils`, `tools`, `documents`

### Writing Effective Descriptions

**Always write in third person.** The description is injected into the system prompt. Inconsistent point-of-view causes discovery problems.
- Good: "Processes Excel files and generates reports"
- Bad: "I can help you process Excel files"
- Bad: "You can use this to process Excel files"

**When-to-use requirements MUST be part of the description**, not just inside the skill file. Claude uses the description to decide whether to load the skill from potentially 100+ available skills.

Bad:
```yaml
description: Helps with PDFs.
```

Good:
```yaml
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

Include specific keywords that help agents identify relevant tasks.

### Degrees of Freedom
Match instruction specificity to the task's fragility:

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** (text guidance) | Multiple valid approaches, context-dependent | "Analyze code structure, check for bugs, suggest improvements" |
| **Medium** (pseudocode/templates) | Preferred pattern exists, some variation OK | Provide a function template with configurable parameters |
| **Low** (exact scripts) | Fragile operations, consistency critical | "Run exactly: `python scripts/migrate.py --verify --backup`" |

Think of it as a path: narrow bridge with cliffs = low freedom (exact steps). Open field = high freedom (general direction).

### Reference File Rules
- Keep references **one level deep** from SKILL.md. Avoid deeply nested chains.
- Name files descriptively: `form_validation_rules.md` not `doc2.md`
- For reference files over 100 lines, include a **table of contents** at the top
- Make execution intent clear: "Run `script.py`" (execute) vs "See `script.py`" (read as reference)

### Workflow Checklists in Skills
For complex multi-step tasks, provide a copyable checklist Claude tracks:

```markdown
## Form filling workflow

Copy this checklist and track progress:

Task Progress:
- [ ] Step 1: Analyze form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

### Feedback Loops
For quality-critical tasks, build validate-fix-repeat loops:

```markdown
## Editing process
1. Make edits
2. Validate immediately: `python scripts/validate.py`
3. If validation fails: review error, fix, validate again
4. Only proceed when validation passes
```

### Plan-Validate-Execute Pattern
For high-stakes operations, require verifiable intermediate outputs:
1. Analyze the input
2. Create a **plan file** (e.g., `changes.json`) describing intended changes
3. **Validate the plan** with a script before executing
4. Execute only after validation passes
5. Verify the output

This catches errors before they're applied and makes debugging easier.

### Avoid Offering Too Many Options
Don't present multiple approaches. Provide a default with an escape hatch:

Bad: "You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image..."
Good: "Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."

### Plugin Architecture (for sharing)
```
my-plugin/
  .claude-plugin/
    plugin.json       # Manifest
  skills/
    review/
      SKILL.md
```
Namespacing prevents conflicts: `/my-plugin:review` won't collide with another team's `/review`.

### Skill Quality Checklist
Before sharing a skill, verify:

**Core quality:**
- [ ] Description is specific, third-person, includes what + when
- [ ] SKILL.md body under 500 lines
- [ ] Additional details in separate files (if needed)
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] File references one level deep
- [ ] Workflows have clear steps with checklists

**Scripts (if applicable):**
- [ ] Scripts handle errors explicitly (don't punt to Claude)
- [ ] No magic numbers (all values justified with comments)
- [ ] Required packages listed and verified
- [ ] No Windows-style paths (use forward slashes)
- [ ] Validation/feedback loops for critical operations

---

## Part 6: Prompting & Instruction Writing Principles

### 10-Part Prompt Structure
1. Task context
2. Tone context
3. Background data/documents
4. Detailed task description & rules
5. Examples of desired output
6. Conversation history for context
7. Immediate task or request
8. "Think step by step" instruction
9. Output formatting requirements
10. Prefilled response to guide the start

### 8 Essential Prompt Engineering Techniques
1. **Meta Prompting** - Ask AI to refine your prompt before answering
2. **Chain-of-Thought** - Break reasoning step-by-step
3. **Tree-of-Thought** - Explore multiple reasoning paths simultaneously
4. **Prompt Chaining** - Link outputs as inputs in a structured flow
5. **Generate Knowledge** - Have AI explain frameworks before solving
6. **RAG** - Combine external data with reasoning
7. **Reflexion** - AI critiques and improves its own response
8. **ReAct** - Plan (reason), perform (act), then deliver result

### Risk-Based Instruction Depth
| Risk Level | Strategy | Components |
|------------|----------|------------|
| Low (brainstorming) | Simple structure | Role + Goal |
| Medium (work tasks) | Add reasoning controls | Context + Constraints |
| High (legal, financial) | Full verification | Verification + Human review |

### Three Things Missing When Output Frustrates You
1. A specific **quality threshold** ("100% fidelity" or "maximally useful")
2. A concrete **structural example** ("here's how to format it")
3. Explicit **verification criteria** ("spell out every acronym")

### Action-Oriented Writing Rules
1. **Bias toward action** - Remove "plan" or "outline" instructions that cause premature stopping. Say: "Complete this fully, don't just outline."
2. **Batch requests** - Ask for multiple things simultaneously
3. **Persist until complete** - Add: "Deliver finished work, not just recommendations or next steps."
4. **Be ruthlessly specific** - Exact format, exact style, exact structure
5. **Avoid AI slop** - Say: "Create something distinctive - avoid generic templates."

### Instruction Language Rules
- Write in **plain strict language**: "create six questions" not "create a few questions"
- **Don't let it make things up**: Say "use 'check this' and don't mark done if claims can't be verified"
- **Provide alternatives, not prohibitions**: "Do Y instead of X because Z" beats "Never do X"
- **Explain reasoning**: Rules with "why" are followed better than bare directives
- **Demand receipts**: Have it add "DONE" or "BLOCKED + reason" so you know what happened
- **Use consistent terminology**: Pick one term and stick with it. Always "API endpoint" (not mixing "URL", "route", "path"). Always "extract" (not mixing "pull", "get", "retrieve").
- **Write in third person** for anything injected into system prompts (skill descriptions, agent personas). "Processes files" not "I help you process files."

---

## Part 7: Agent Organization Principles

### Lessons from Organizational Theory
- **Spans of control**: A human tops out at <10 direct reports. 100 subagents is too many for an orchestrator. Use middle-management agents.
- **Boundary objects**: Structured artifacts passed between agents (not raw text). Multiple agents of different abilities should be able to read/write to them. Reduces coordination failures and token use.
- **Coupling**: Most systems are either too tightly coupled (every step needs approval) or too loose. Find the right balance.
- **Bounded rationality**: Agents have limited context. Design for that limitation.

### Scope & Duplicate Prevention
- **Scope precisely**: "Work only on this page and its subpages" to avoid unwanted changes
- **Don't create duplicates**: Make it update existing content instead of creating new copies
- **Create run logs**: Track each change as if it needs to be undone
- **Think tables-first**: Databases/tables over raw text. Easier to sort, review, and fix.

---

## Part 8: Anti-Patterns Checklist

| Anti-Pattern | Fix |
|---|---|
| Bloated CLAUDE.md (2000+ lines) | Progressive disclosure: concise root + detailed docs |
| Auto-generated CLAUDE.md | Hand-craft every line |
| Style rules in CLAUDE.md | Use linters and formatters |
| Vague agent descriptions | Specific persona + boundaries + examples |
| Skills without when-to-use in description | Put trigger conditions in the description field |
| No boundaries defined | Use always-do / ask-first / never-do tiers |
| Pasting code snippets | Use `file:path:line` references instead |
| "Never do X" without alternative | "Do Y instead of X because Z" |
| Skipping planning | Plan > Execute > Test > Commit loop |
| No self-review step | Have Claude review its own output before proceeding |
| Raw text between agents | Use structured boundary objects |
| Too many subagents on one orchestrator | Add middle-management layer |
| Telling AI what NOT to do | Tell it what TO DO instead (the toddler principle) |
| Asking for output without quality threshold | Add specific quality criteria |
| One-shot prompting for complex tasks | Use technique selection: CoT for simple, ToT + Reflexion for complex |
| No self-correction protocol | Add instructions for agent to update docs when it discovers mismatches |
| Repeating the same correction across sessions | Write it into Local Norms so it persists |
| Exhaustive file listing in code map | Focus on high-signal files (entry points, config, naming conventions) |
| Explaining things Claude already knows | Only add context unique to your project ("Claude is already smart") |
| Skill description in first/second person | Always use third person ("Processes files" not "I help you process") |
| Offering too many tool/library options | Provide one default with escape hatch for edge cases |
| Deeply nested file references | Keep references one level deep from SKILL.md |
| Writing docs before evaluations | Build 3 eval scenarios first, then write minimal docs to pass them |
| Time-sensitive instructions | Use "current method" + collapsible "old patterns" section |
| Inconsistent terminology | Pick one term per concept and use it everywhere |
| Magic numbers in scripts | Document why every constant has its value |

---

## Part 9: Self-Improvement & Iteration

### Core Principle
> "If the model weights are not changing mid-week, improvement has to come from the environment you wrap around the agent."

The agent doesn't get smarter between sessions. Your docs do. That's the lever.

### The Self-Improvement Loop
1. Start with: name, description, persona, commands, code map, local norms
2. Observe a mismatch between agent behavior and your preferences
3. Provide explicit correction in the conversation
4. Agent writes the correction into CLAUDE.md, agents.md, or a docs file
5. Next session, agent reads the updated context and behaves correctly
6. Repeat

```
Mistake observed > Correct agent > Agent writes to docs > Load next session > Better output
```

### Self-Correction Protocols
Add explicit instructions in your CLAUDE.md/agents.md telling the agent to update its own documentation:

- **Stale map detection**: "When you discover the code map doesn't match reality (new files, moved directories, renamed modules), update the Code Map section before continuing."
- **User feedback integration**: "When I correct your behavior, add the correction to the Local Norms section so it persists across sessions."
- **Optional refresh cadence**: "Review and update the code map weekly" - though on-demand updates from mismatches create more responsive loops.

This transforms the relationship from "babysitting a fast intern" into genuine environmental improvement that compounds over time.

### Evaluation-Driven Development
**Create evaluations BEFORE writing extensive documentation.** This ensures you solve real problems, not imagined ones.

1. **Identify gaps**: Run Claude on representative tasks *without* a skill. Document specific failures.
2. **Create evaluations**: Build 3 scenarios that test those gaps.
3. **Establish baseline**: Measure performance without the skill.
4. **Write minimal instructions**: Just enough to address the gaps and pass evaluations.
5. **Iterate**: Run evals, compare against baseline, refine.

### The Claude A / Claude B Pattern
Use one Claude instance ("Claude A") to create skills, another ("Claude B") to test them:

1. Complete a task with Claude A using normal prompting. Notice what context you repeatedly provide.
2. Ask Claude A to capture that pattern as a skill.
3. Review for conciseness: "Remove the explanation about what X means - Claude already knows that."
4. Test with Claude B (fresh instance with the skill loaded) on real tasks.
5. Observe Claude B's behavior. Where does it struggle?
6. Return to Claude A: "Claude B forgot to filter test accounts. How should we fix the skill?"
7. Repeat.

Watch for: unexpected file reading order, missed references, overreliance on certain sections, ignored content. Iterate based on observed behavior, not assumptions.

### Iteration Philosophy
> Start minimal and grow based on observed failures. The best files grow through iteration, not upfront planning.

Don't try to write the perfect file upfront. The bootstrap is good enough to start; the corrections make it great.

---

## Quick Reference: File Purposes

| File | Purpose | Loaded |
|---|---|---|
| `CLAUDE.md` | Project rules, commands, structure | Always (auto) |
| `agents.md` | Agent personas, boundaries, workflows | Always (auto, Copilot) |
| `docs/*.md` | Domain knowledge, gotchas, schemas | On-demand |
| `.claude/skills/*/SKILL.md` | Auto-discovered capabilities | When description matches |
| `.claude/commands/*.md` | Manual slash commands | On `/invoke` |
| `plan.md` | Current task plan and approach | Referenced by Claude |
| `context.md` | Key decisions and relevant files | Referenced by Claude |
| `tasks.md` | Progress checklist | Referenced by Claude |
