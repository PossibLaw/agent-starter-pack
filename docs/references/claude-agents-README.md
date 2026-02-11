# Claude Code Global Agents

A collection of reusable Claude Code sub-agents available across all your projects.

## 📋 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Available Agents](#available-agents)
- [Usage](#usage)
- [Creating Custom Agents](#creating-custom-agents)
- [Troubleshooting](#troubleshooting)
- [Updating Agents](#updating-agents)

---

## 🎯 Overview

This setup provides globally available Claude Code sub-agents that you can invoke from any project directory. Each agent is specialized for specific development tasks and follows a structured workflow to ensure quality outputs.

### What are Sub-Agents?

Sub-agents are specialized Claude instances with custom instructions for specific tasks. They run independently with their own context and can be invoked from any project.

### Benefits

- **Reusable**: Write once, use in all projects
- **Consistent**: Same quality and approach across projects
- **Convenient**: Simple aliases for quick access
- **Maintainable**: Update once, affects all usage

---

## 🚀 Installation

### Quick Install

```bash
# Run the installer
~/.claude/agents/install.sh

# Activate aliases (choose your shell)
source ~/.bashrc    # for bash
source ~/.zshrc     # for zsh
```

### Manual Installation

If you need to set up manually:

1. **Create the agents directory:**
   ```bash
   mkdir -p ~/.claude/agents
   ```

2. **Add agents** (see [Creating Custom Agents](#creating-custom-agents))

3. **Add aliases to your shell config** (`~/.bashrc` or `~/.zshrc`):
   ```bash
   # Claude Code Agents
   alias cplan='claude code --agent ~/.claude/agents/task-planner.md'
   alias ctest='claude code --agent ~/.claude/agents/test-generator.md'
   alias cagents='ls -1 ~/.claude/agents/*.md 2>/dev/null | xargs -n1 basename'
   ```

4. **Reload shell config:**
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

---

## 🤖 Available Agents

### Task Planner (`task-planner.md`)

**Purpose**: Creates detailed implementation plans for features and goals

**What it does:**
- Asks clarifying questions about your goal
- Analyzes project files (`claude.md`, `readme.md`)
- Validates assumptions with you
- Creates a structured task list with dependencies
- Saves plan to `TASK_PLAN.md`

**When to use:**
- Starting a new feature
- Planning refactoring work
- Breaking down complex requirements
- Before diving into implementation

**Workflow:**
1. Initial discovery questions
2. File analysis
3. Assumption validation
4. Task list creation
5. Plan confirmation

**Example usage:**
```bash
cplan "Add user authentication with JWT tokens"
cplan "Refactor the database layer to use TypeORM"
cplan "Implement real-time notifications using WebSockets"
```

---

### Test Generator (`test-generator.md`)

**Purpose**: Generates comprehensive test suites for code files and features

**What it does:**
- Asks about testing scope and requirements
- Analyzes code to identify test scenarios
- Proposes a testing strategy
- Generates well-structured tests
- Provides coverage summary and recommendations

**When to use:**
- Adding tests to existing code
- Testing new features
- Improving test coverage
- Learning testing patterns

**Workflow:**
1. Understanding testing scope
2. Code analysis
3. Test strategy presentation
4. Test generation
5. Review and recommendations

**Supports:**
- Unit tests
- Integration tests
- E2E tests
- Multiple frameworks (Jest, pytest, Go testing, etc.)

**Example usage:**
```bash
ctest "Generate unit tests for src/utils/auth.js"
ctest "Create integration tests for the payment API"
ctest "Add E2E tests for the checkout flow"
```

---

## 💻 Usage

### Basic Commands

```bash
# List all available agents
cagents

# Use task planner
cplan "your goal or feature description"

# Use test generator
ctest "what to test"

# Use any agent directly
claude code --agent ~/.claude/agents/task-planner.md "your prompt"
```

### Working with Agents

Agents follow conversational workflows:

```bash
# Start the agent
cplan "Add OAuth authentication"

# Agent will ask clarifying questions
# Answer them in the conversation

# Agent will analyze your project files
# Wait for it to present findings

# Agent will validate assumptions
# Confirm or correct them

# Agent will generate the output
# Review and provide feedback
```

### Tips for Best Results

1. **Be specific in your initial prompt:**
   - ❌ "Add authentication"
   - ✅ "Add OAuth 2.0 authentication with Google and GitHub providers"

2. **Have project documentation ready:**
   - Ensure `claude.md` and `README.md` exist
   - Keep them up to date

3. **Answer questions thoughtfully:**
   - Agents ask questions to avoid assumptions
   - Clear answers = better outputs

4. **Iterate as needed:**
   - Review generated outputs
   - Request adjustments
   - Refine until satisfied

---

## 🛠️ Creating Custom Agents

### Agent File Structure

Create a new file in `~/.claude/agents/` with this structure:

```markdown
---
name: Your Agent Name
description: What this agent does
agent: true
---

# Your Agent Title

## Your Role
[Define what this agent specializes in]

## Workflow
[Step-by-step process the agent follows]

### Phase 1: [Phase Name]
[What happens in this phase]

### Phase 2: [Phase Name]
[What happens in this phase]

## Guidelines
[Important rules and principles]

## Examples
[Usage examples and expected outputs]
```

### Example: Code Reviewer Agent

```markdown
---
name: Code Reviewer
description: Performs thorough code reviews with actionable feedback
agent: true
---

# Code Reviewer Agent

## Your Role
You are a senior code reviewer who provides constructive, actionable feedback on code quality, best practices, and potential issues.

## Workflow

### Phase 1: Review Scope
Ask:
1. Which files or components to review?
2. Any specific concerns or focus areas?
3. Project language and framework context?

### Phase 2: Code Analysis
Analyze for:
- Code quality and readability
- Potential bugs and edge cases
- Performance considerations
- Security vulnerabilities
- Best practices adherence
- Test coverage

### Phase 3: Feedback Report
Provide:
- Summary of findings
- Critical issues (must fix)
- Improvements (should fix)
- Suggestions (nice to have)
- Positive observations
```

### Agent Best Practices

1. **Clear Role Definition**: Specify exactly what the agent does
2. **Structured Workflow**: Break down into clear phases
3. **Ask Questions First**: Clarify before acting
4. **Validate Assumptions**: Check understanding with user
5. **Provide Context**: Explain reasoning and decisions
6. **Be Conversational**: Natural language, not robotic

---

## 🔧 Troubleshooting

### Aliases Not Working

**Problem**: `cplan: command not found`

**Solution**:
```bash
# Reload your shell configuration
source ~/.bashrc   # or ~/.zshrc

# Verify aliases are set
alias | grep cplan

# If not found, run the installer again
~/.claude/agents/install.sh
```

### Agent Not Found

**Problem**: `Agent file not found: ~/.claude/agents/task-planner.md`

**Solution**:
```bash
# Check if agents exist
ls -la ~/.claude/agents/

# If missing, recreate them (see Installation section)
# Or download from your backup/repository
```

### Agent Doesn't Follow Instructions

**Problem**: Agent behaves differently than expected

**Solution**:
1. Check the agent file syntax (YAML front matter correct?)
2. Review the agent instructions for clarity
3. Test with a simple prompt first
4. Update Claude Code to latest version:
   ```bash
   npm update -g @anthropic-ai/claude-code
   ```

### Permission Errors

**Problem**: Cannot execute `install.sh`

**Solution**:
```bash
chmod +x ~/.claude/agents/install.sh
```

### Path Issues

**Problem**: Agent works in one terminal but not another

**Solution**:
- Ensure aliases are in the correct shell config file
- Use full path as fallback:
  ```bash
  claude code --agent ~/.claude/agents/task-planner.md "prompt"
  ```

---

## 🔄 Updating Agents

### Update Existing Agent

```bash
# Edit the agent file
nano ~/.claude/agents/task-planner.md

# Changes take effect immediately
# No need to reload shell config
```

### Update Aliases

```bash
# Edit your shell config
nano ~/.bashrc  # or ~/.zshrc

# Add/modify aliases in the Claude Code Agents section

# Reload
source ~/.bashrc  # or ~/.zshrc
```

### Backup Agents

```bash
# Create a backup
tar -czf ~/claude-agents-backup-$(date +%Y%m%d).tar.gz ~/.claude/agents/

# Restore from backup
tar -xzf ~/claude-agents-backup-20240101.tar.gz -C ~/
```

### Version Control (Recommended)

```bash
# Initialize git repository
cd ~/.claude/agents
git init
git add .
git commit -m "Initial agent setup"

# Push to remote (optional)
git remote add origin https://github.com/yourusername/claude-agents.git
git push -u origin main

# Update from remote
git pull
```

---

## 📚 Advanced Usage

### Combining Agents

Use multiple agents in sequence for complex workflows:

```bash
# 1. Plan the implementation
cplan "Add payment processing with Stripe"

# 2. Review generated plan
# (review TASK_PLAN.md)

# 3. After implementation, generate tests
ctest "Generate tests for payment processing module"

# 4. Review the implementation
creview "Review src/payment/ directory"
```

### Custom Agent Shortcuts

Add project-specific shortcuts to your project's `claude.md`:

```markdown
## Quick Commands

### /plan-feature
Alias for: `cplan`

### /test-all
Run: `ctest "Generate tests for all untested files in src/"`

### /review-pr
Run: `creview "Review all changes in current git branch"`
```

### Environment-Specific Agents

Create variants for different contexts:

```bash
~/.claude/agents/
├── task-planner.md           # General planning
├── task-planner-frontend.md  # Frontend-specific
├── task-planner-backend.md   # Backend-specific
└── task-planner-mobile.md    # Mobile-specific
```

---

## 📖 Additional Resources

### Learning More

- [Claude Code Documentation](https://docs.claude.ai/)
- [Anthropic Prompt Engineering](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)

### Community

- Share your agents with the community
- Learn from others' agent designs
- Contribute improvements

### Getting Help

If you run into issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review agent file syntax
3. Test with simple prompts
4. Check Claude Code version: `claude code --version`
5. Consult Claude Code documentation

---

## 📝 Quick Reference

### File Locations

```
~/.claude/agents/          # Agent definitions
~/.bashrc or ~/.zshrc      # Shell aliases
~/.config/claude-code/     # Claude Code config (if used)
```

### Common Commands

```bash
cagents                    # List all agents
cplan "prompt"            # Task planner
ctest "prompt"            # Test generator
creview "prompt"          # Code reviewer (if created)

# Direct usage
claude code --agent ~/.claude/agents/AGENT_NAME.md "prompt"

# Management
~/.claude/agents/install.sh  # Reinstall/update
nano ~/.claude/agents/AGENT_NAME.md  # Edit agent
```

### Agent Template

```markdown
---
name: Agent Name
description: One-line description
agent: true
---

# Agent Title

## Your Role
[What this agent does]

## Workflow
1. [Phase 1]
2. [Phase 2]
3. [Phase 3]

## Guidelines
- [Important rule 1]
- [Important rule 2]
```

---

## 🎉 You're All Set!

Your global Claude Code agents are ready to use. Start with:

```bash
cplan "Your first feature or goal"
```

Happy coding! 🚀

---

**Last Updated**: 2025-01-27  
**Version**: 1.0  
**Maintained by**: You
