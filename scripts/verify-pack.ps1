#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path

$requiredFiles = @(
  "README.md",
  "CHANGELOG.md",
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
  "packs/project/docs/vendor/README.md",
  "packs/project/docs/vendor/supabase.md",
  "packs/project/docs/workflows/evals.md",
  "packs/project/docs/workflows/contracts.md",
  "packs/project/docs/workflows/wiki.md",
  "packs/project/.claude/history.md",
  "packs/project/.agent/PLAN.md",
  "packs/project/.agent/CONTEXT.md",
  "packs/project/.agent/TASKS.md",
  "packs/project/.agent/REVIEW.md",
  "packs/project/.agent/TEST.md",
  "packs/project/.agent/HANDOFF.md",
  "packs/project/.agent/LEARNINGS.md",
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
  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $_.FullName) {
    $lineNumber += 1
    foreach ($match in [regex]::Matches($line, $tokenRegex)) {
      if (-not $allowedTokens.Contains($match.Value)) {
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName).Replace('\', '/')
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
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Contract Pipeline (Required)" -Message "missing contract pipeline section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Contract Pipeline (Required)" -Message "missing contract pipeline section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/CLAUDE.md") -Pattern "## Optional Wiki Mode (Default OFF)" -Message "missing wiki mode section in packs/project/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/AGENTS.md") -Pattern "## Optional Wiki Mode (Default OFF)" -Message "missing wiki mode section in packs/project/AGENTS.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Memory Backend (MemPalace)" -Message "missing mempalace section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Skill Workflow Integration (gstack-inspired)" -Message "missing gstack section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/contracts.md") -Pattern "## Optional Wiki Mode Integration (Karpathy Pattern)" -Message "missing wiki integration section in packs/project/docs/workflows/contracts.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/docs/workflows/wiki.md") -Pattern "## Trust Order (Required)" -Message "missing trust order section in packs/project/docs/workflows/wiki.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/PLAN.md") -Pattern "contract_version: 1" -Message "missing contract header in packs/project/.agent/PLAN.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/PLAN.md") -Pattern "artifact_type: plan" -Message "missing plan artifact_type in packs/project/.agent/PLAN.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/TEST.md") -Pattern "artifact_type: test" -Message "missing test artifact_type in packs/project/.agent/TEST.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/REVIEW.md") -Pattern "artifact_type: review" -Message "missing review artifact_type in packs/project/.agent/REVIEW.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/project/.agent/HANDOFF.md") -Pattern "artifact_type: handoff" -Message "missing handoff artifact_type in packs/project/.agent/HANDOFF.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/global/claude/.claude/CLAUDE.md") -Pattern "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." -Message "missing vendor recency rule in packs/global/claude/.claude/CLAUDE.md"
Require-Text -FilePath (Join-Path $repoRoot "packs/global/codex/.codex/AGENTS.md") -Pattern "For vendor setup/API/security guidance, verify against official vendor docs and cite source date." -Message "missing vendor recency rule in packs/global/codex/.codex/AGENTS.md"

Write-Host "DONE: verification passed"
