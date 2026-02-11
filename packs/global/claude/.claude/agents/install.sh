#!/bin/bash

# Claude Code Agent Manager
# Installs and manages global Claude Code sub-agents

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

AGENT_DIR="$HOME/.claude/agents"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}     Claude Code Agent Manager${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Ensure agent directory exists
mkdir -p "$AGENT_DIR"
echo -e "${GREEN}✓${NC} Agent directory: $AGENT_DIR"

# Detect shell configuration file
SHELL_CONFIG=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo -e "${YELLOW}⚠${NC}  Could not detect shell config (.bashrc or .zshrc)"
    echo -e "   Please manually add aliases to your shell configuration"
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected shell: $SHELL_NAME ($SHELL_CONFIG)"
echo

# Check if aliases already exist
if grep -q "# Claude Code Agents" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  Aliases already exist in $SHELL_CONFIG"
    read -p "   Overwrite existing aliases? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ${NC}  Skipping alias installation"
        SKIP_ALIASES=true
    else
        # Remove old aliases
        sed -i.bak '/# Claude Code Agents/,/^$/d' "$SHELL_CONFIG"
        echo -e "${GREEN}✓${NC} Removed old aliases"
    fi
fi

# Add aliases to shell config
if [[ "$SKIP_ALIASES" != true ]]; then
    cat >> "$SHELL_CONFIG" << 'ALIASES'

# Claude Code Agents
alias cplan='claude code --agent ~/.claude/agents/task-planner.md'
alias ctest='claude code --agent ~/.claude/agents/test-generator.md'
alias cagents='ls -1 ~/.claude/agents/*.md 2>/dev/null | xargs -n1 basename'

ALIASES
    echo -e "${GREEN}✓${NC} Aliases added to $SHELL_CONFIG"
fi

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# List available agents
echo -e "${BLUE}Available Agents:${NC}"
if ls "$AGENT_DIR"/*.md 1> /dev/null 2>&1; then
    for agent in "$AGENT_DIR"/*.md; do
        agent_name=$(basename "$agent" .md)
        # Extract description from agent file if it exists
        description=$(grep "^description:" "$agent" 2>/dev/null | cut -d: -f2- | xargs)
        if [[ -n "$description" ]]; then
            echo -e "  ${GREEN}•${NC} ${agent_name}: ${description}"
        else
            echo -e "  ${GREEN}•${NC} ${agent_name}"
        fi
    done
else
    echo -e "  ${YELLOW}⚠${NC}  No agents found in $AGENT_DIR"
    echo -e "     Create agents with: nano ~/.claude/agents/my-agent.md"
fi

echo
echo -e "${BLUE}Available Commands:${NC}"
echo -e "  ${GREEN}cplan${NC}   - Task planning agent"
echo -e "  ${GREEN}ctest${NC}   - Test generation agent"
echo -e "  ${GREEN}cagents${NC} - List all available agents"

echo
echo -e "${YELLOW}⚠${NC}  Run this command to activate aliases in current session:"
echo -e "   ${BLUE}source $SHELL_CONFIG${NC}"

echo
echo -e "${BLUE}Usage Examples:${NC}"
echo -e "  ${GREEN}cplan${NC} \"Add user authentication with JWT\""
echo -e "  ${GREEN}ctest${NC} \"Generate tests for src/utils/auth.js\""
echo -e "  ${GREEN}claude code --agent ~/.claude/agents/task-planner.md${NC} \"your goal\""

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
