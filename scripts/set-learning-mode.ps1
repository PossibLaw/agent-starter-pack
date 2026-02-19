#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
  @'
Set Learning Mode in a target repository's .agent/PLAN.md.

Usage:
  set-learning-mode.ps1 <MODE>
  set-learning-mode.ps1 /path/to/target-repo <MODE>

Modes:
  OFF
  CAPTURE
  APPLY
'@ | Write-Host
}

if ($args.Count -lt 1 -or $args.Count -gt 2) {
  Show-Usage
  exit 1
}

$targetDir = "."
$modeRaw = ""

if ($args.Count -eq 1) {
  $modeRaw = [string]$args[0]
} else {
  $targetDir = [string]$args[0]
  $modeRaw = [string]$args[1]
}

if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
  Write-Host "BLOCKED: target directory does not exist: $targetDir"
  exit 1
}

$targetDir = (Resolve-Path -LiteralPath $targetDir).Path
$mode = $modeRaw.ToUpperInvariant()
if (@("OFF", "CAPTURE", "APPLY") -notcontains $mode) {
  Write-Host "BLOCKED: invalid mode: $modeRaw"
  Show-Usage
  exit 1
}

$planFile = Join-Path $targetDir ".agent/PLAN.md"
if (-not (Test-Path -LiteralPath $planFile -PathType Leaf)) {
  Write-Host "BLOCKED: missing file: $planFile"
  exit 1
}

$modeLine = "- Mode: ``$mode``"
if ($mode -eq "OFF") {
  $modeLine = "$modeLine (default)"
}

$lines = @(Get-Content -LiteralPath $planFile)
$inSection = $false
$replaced = $false

for ($i = 0; $i -lt $lines.Count; $i += 1) {
  $line = $lines[$i]
  if ($line -eq "## Learning Mode") {
    $inSection = $true
    continue
  }
  if ($inSection -and $line -match '^## ') {
    $inSection = $false
  }
  if ($inSection -and -not $replaced -and $line -match '^- Mode:') {
    $lines[$i] = $modeLine
    $replaced = $true
    continue
  }
}

if (-not $replaced) {
  Write-Host "BLOCKED: could not find '- Mode:' under '## Learning Mode' in $planFile"
  exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item -LiteralPath $planFile -Destination "$planFile.bak.$timestamp" -Force
Set-Content -LiteralPath $planFile -Value $lines

Write-Host "DONE: set Learning Mode to $mode in $planFile"
