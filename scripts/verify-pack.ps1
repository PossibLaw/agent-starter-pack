#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path

$requiredFiles = @(
  "README.md",
  "CHANGELOG.md",
  ".claude-plugin/plugin.json",
  "skills/closing-sprint-and-syncing-state/SKILL.md",
  "skills/running-novice-safe-git-cycle/SKILL.md",
  "hooks/hooks.json",
  "scripts/guardrails/validate-bash.py",
  "tests/guardrails/test_validate_bash.py",
  "scripts/bootstrap-project.sh",
  "scripts/install-project.sh",
  "scripts/install-global.sh",
  "scripts/verify-pack.sh",
  "scripts/set-learning-mode.sh",
  "scripts/bootstrap-project.ps1",
  "scripts/install-project.ps1",
  "scripts/install-global.ps1",
  "scripts/verify-pack.ps1",
  "scripts/set-learning-mode.ps1",
  "packs/project/AGENTS.md",
  "packs/project/CLAUDE.md",
  "packs/project/docs/roles/README.md",
  "packs/project/docs/roles/product-strategist.md",
  "packs/project/docs/roles/engineering-planner.md",
  "packs/project/docs/roles/reviewer.md",
  "packs/project/docs/roles/security-reviewer.md",
  "packs/project/docs/roles/qa-validator.md",
  "packs/project/docs/roles/docs-releaser.md",
  "packs/project/docs/vendor/README.md",
  "packs/project/docs/vendor/supabase.md",
  "packs/project/docs/workflows/evals.md",
  "packs/project/docs/workflows/contracts.md",
  "packs/project/docs/workflows/wiki.md",
  "packs/project/docs/workflows/graphify.md",
  "packs/project/docs/glossary.md",
  "packs/project/.claude/history.md",
  "packs/project/.agent/PLAN.md",
  "packs/project/.agent/CONTEXT.md",
  "packs/project/.agent/TASKS.md",
  "packs/project/.agent/REVIEW.md",
  "packs/project/.agent/TEST.md",
  "packs/project/.agent/HANDOFF.md",
  "packs/project/.agent/WIKI.md",
  "packs/project/.agent/LEARNINGS.md",
  "packs/project/.agent/integrations/README.md",
  "packs/project/.agent/integrations/run-checkpoint.sh",
  "packs/project/.agent/integrations/run-checkpoint.ps1",
  "packs/project/.agent/integrations/mempalace-ingest.sh",
  "packs/project/.agent/integrations/mempalace-ingest.ps1",
  "packs/global/codex/.codex/AGENTS.md",
  "packs/global/claude/.claude/CLAUDE.md"
)

$forbiddenPatterns = @(
  "packs/global/claude/.claude/debug",
  "packs/global/claude/.claude/projects",
  "packs/global/claude/.claude/cache",
  "packs/global/claude/.claude/history.jsonl",
  "packs/global/codex/.codex/auth.json",
  "packs/global/codex/.codex/history.jsonl",
  "packs/global/codex/.codex/sessions"
)

$missing = $false
foreach ($relativePath in $requiredFiles) {
  $fullPath = Join-Path $repoRoot $relativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    Write-Host "BLOCKED: missing required file: $relativePath"
    $missing = $true
  }
}
if ($missing) {
  exit 1
}

foreach ($relativePath in $forbiddenPatterns) {
  $fullPath = Join-Path $repoRoot $relativePath
  if (Test-Path -LiteralPath $fullPath) {
    Write-Host "BLOCKED: forbidden path present: $relativePath"
    exit 1
  }
}

$allowedTokens = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
@(
  "<PROJECT_NAME>",
  "<TEAM_OR_OWNER>",
  "<PRIMARY_COMMAND>",
  "<TEST_COMMAND>",
  "<LINT_COMMAND>",
  "<TYPECHECK_COMMAND>",
  "<BUILD_COMMAND>"
) | ForEach-Object {
  [void]$allowedTokens.Add($_)
}

$unexpected = New-Object System.Collections.Generic.List[string]
$tokenRegex = '<[A-Z_]+>'
$packRoot = Join-Path $repoRoot "packs"

Get-ChildItem -LiteralPath $packRoot -Recurse -File | ForEach-Object {
  $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName).Replace('\\', '/')
  if ($relativePath -split '/' | Where-Object { $_.StartsWith('.') }) {
    return
  }

  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $_.FullName) {
    $lineNumber += 1
    foreach ($match in [regex]::Matches($line, $tokenRegex)) {
      if (-not $allowedTokens.Contains($match.Value)) {
        $unexpected.Add("$relativePath`:$lineNumber`:$($match.Value)")
      }
    }
  }
}

if ($unexpected.Count -gt 0) {
  Write-Host "BLOCKED: unexpected placeholder(s) found:"
  $unexpected | ForEach-Object { Write-Host $_ }
  exit 1
}

function Require-Text {
  param(
    [string]$FilePath,
    [string]$Pattern,
    [string]$Message
  )

  $content = Get-Content -LiteralPath $FilePath -Raw
  if (-not $content.Contains($Pattern)) {
    Write-Host "BLOCKED: $Message"
    exit 1
  }
}

Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Vendor References" -Message "missing vendor section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Vendor References" -Message "missing vendor section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/roles/README.md") -Pattern "## Canonical Roles" -Message "missing canonical role table in packs/project/docs/roles/README.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Contract Pipeline (Required)" -Message "missing contract pipeline section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Contract Pipeline (Required)" -Message "missing contract pipeline section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Continuity Checkpoint Contract" -Message "missing checkpoint section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Continuity Checkpoint Contract" -Message "missing checkpoint section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Optional Wiki Mode (Default OFF)" -Message "missing wiki mode section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Optional Wiki Mode (Default OFF)" -Message "missing wiki mode section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern ".agent/WIKI.md" -Message "missing wiki config pointer in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern ".agent/WIKI.md" -Message "missing wiki config pointer in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Memory Backend (MemPalace)" -Message "missing mempalace section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Continuity Checkpoints (Required)" -Message "missing checkpoint section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Skill Workflow Integration (gstack-inspired)" -Message "missing gstack section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Wiki Mode Integration (Karpathy Pattern)" -Message "missing wiki integration section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/wiki.md") -Pattern "## Trust Order (Required)" -Message "missing trust order section in packs/project/docs/workflows/wiki.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/graphify.md") -Pattern "## Graphify Indexing Request Contract" -Message "missing graphify indexing request contract in packs/project/docs/workflows/graphify.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/WIKI.md") -Pattern "artifact_type: wiki_config" -Message "missing wiki config artifact_type in packs/project/.agent/WIKI.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/WIKI.md") -Pattern 'Vault root (absolute): `UNCONFIRMED`' -Message "missing vault-path setup marker in packs/project/.agent/WIKI.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "Graphify codebase indexing request" -Message "missing graphify startup trigger in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "Graphify codebase indexing request" -Message "missing graphify startup trigger in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/PLAN.md") -Pattern "contract_version: 1" -Message "missing contract header in packs/project/.agent/PLAN.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/PLAN.md") -Pattern "artifact_type: plan" -Message "missing plan artifact_type in packs/project/.agent/PLAN.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/PLAN.md") -Pattern "## Continuity Checkpoint" -Message "missing checkpoint section in packs/project/.agent/PLAN.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/TEST.md") -Pattern "artifact_type: test" -Message "missing test artifact_type in packs/project/.agent/TEST.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/REVIEW.md") -Pattern "artifact_type: review" -Message "missing review artifact_type in packs/project/.agent/REVIEW.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/HANDOFF.md") -Pattern "artifact_type: handoff" -Message "missing handoff artifact_type in packs/project/.agent/HANDOFF.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/HANDOFF.md") -Pattern "## Sprint / Git Cycle" -Message "missing sprint git section in packs/project/.agent/HANDOFF.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/integrations/README.md") -Pattern "Optional MemPalace Hook" -Message "missing MemPalace hook contract in integrations README"
Require-Text -FilePath (Join-Path $repoRoot "skills/closing-sprint-and-syncing-state/SKILL.md") -Pattern "name: closing-sprint-and-syncing-state" -Message "missing closing sprint skill metadata"
Require-Text -FilePath (Join-Path $repoRoot "skills/running-novice-safe-git-cycle/SKILL.md") -Pattern "name: running-novice-safe-git-cycle" -Message "missing git cycle skill metadata"
Require-Text -FilePath (Join-Path $repoRoot ".claude-plugin/plugin.json") -Pattern '"name": "possiblaw-starter"' -Message "missing plugin name in .claude-plugin/plugin.json"

$agentsDir = Join-Path $repoRoot "agents"
if (-not (Test-Path -LiteralPath $agentsDir -PathType Container)) {
  Write-Host "BLOCKED: missing top-level agents directory: $agentsDir"
  exit 1
}
$agentMdCount = (Get-ChildItem -LiteralPath $agentsDir -Filter "*.md" -File | Measure-Object).Count
if ($agentMdCount -lt 10) {
  Write-Host "BLOCKED: expected at least 10 agent .md files in agents/, found $agentMdCount"
  exit 1
}

$validateBash = Join-Path $repoRoot "scripts/guardrails/validate-bash.py"
if (-not (Test-Path -LiteralPath $validateBash -PathType Leaf)) {
  Write-Host "BLOCKED: missing scripts/guardrails/validate-bash.py"
  exit 1
}
Require-Text -FilePath (Join-Path $repoRoot "packs/global/claude/.claude/CLAUDE.md") -Pattern "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." -Message "missing vendor recency rule in packs/global/claude/.claude/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/global/codex/.codex/AGENTS.md") -Pattern "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." -Message "missing vendor recency rule in packs/global/codex/.codex/AGENTS.md"

Write-Host "DONE: verification passed"
