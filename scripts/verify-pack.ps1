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

Write-Host "DONE: verification passed"
