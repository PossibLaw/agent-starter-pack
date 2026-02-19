#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
  @'
Install optional global Claude/Codex instruction files into the user's HOME.

Usage:
  install-global.ps1 [--claude] [--codex] [--all] [--home /custom/home] [--dry-run]

Options:
  --claude     Install ~/.claude/CLAUDE.md and ~/.claude/agents/*
  --codex      Install ~/.codex/AGENTS.md
  --all        Install both Claude and Codex global files
  --home       Override HOME (useful for testing)
  --dry-run    Print intended actions only
  -h, --help
'@ | Write-Host
}

function Resolve-RequiredOptionValue {
  param(
    [string]$OptionName,
    [int]$CurrentIndex,
    [object[]]$Arguments
  )

  if ($CurrentIndex + 1 -ge $Arguments.Count) {
    Write-Host "BLOCKED: missing value for $OptionName"
    Show-Usage
    exit 1
  }

  return [string]$Arguments[$CurrentIndex + 1]
}

$installClaude = $false
$installCodex = $false
$dryRun = $false
$homeOverride = ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$index = 0
while ($index -lt $args.Count) {
  $arg = [string]$args[$index]
  switch ($arg) {
    "--claude" {
      $installClaude = $true
      $index += 1
      continue
    }
    "--codex" {
      $installCodex = $true
      $index += 1
      continue
    }
    "--all" {
      $installClaude = $true
      $installCodex = $true
      $index += 1
      continue
    }
    "--home" {
      $homeOverride = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--dry-run" {
      $dryRun = $true
      $index += 1
      continue
    }
    "-h" {
      Show-Usage
      exit 0
    }
    "--help" {
      Show-Usage
      exit 0
    }
    default {
      Write-Host "BLOCKED: unknown option: $arg"
      Show-Usage
      exit 1
    }
  }
}

if (-not $installClaude -and -not $installCodex) {
  Write-Host "BLOCKED: choose at least one of --claude, --codex, or --all"
  Show-Usage
  exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path
$packClaude = Join-Path $repoRoot "packs/global/claude/.claude"
$packCodex = Join-Path $repoRoot "packs/global/codex/.codex"
$targetHome = if (-not [string]::IsNullOrWhiteSpace($homeOverride)) { $homeOverride } else { $HOME }

if (-not (Test-Path -LiteralPath $targetHome -PathType Container)) {
  Write-Host "BLOCKED: home path does not exist: $targetHome"
  exit 1
}

$targetHome = (Resolve-Path -LiteralPath $targetHome).Path

if ($installClaude -and -not (Test-Path -LiteralPath $packClaude -PathType Container)) {
  Write-Host "BLOCKED: missing Claude pack: $packClaude"
  exit 1
}

if ($installCodex -and -not (Test-Path -LiteralPath $packCodex -PathType Container)) {
  Write-Host "BLOCKED: missing Codex pack: $packCodex"
  exit 1
}

function Copy-WithBackup {
  param(
    [string]$Src,
    [string]$Dst
  )

  if (-not (Test-Path -LiteralPath $Src -PathType Leaf)) {
    Write-Host "BLOCKED: source file missing: $Src"
    exit 1
  }

  $parentDir = Split-Path -Parent $Dst
  if (-not [string]::IsNullOrWhiteSpace($parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
  }

  if (Test-Path -LiteralPath $Dst) {
    if ($dryRun) {
      Write-Host "DRY_RUN backup: $Dst -> $Dst.bak.$timestamp"
    } else {
      Copy-Item -LiteralPath $Dst -Destination "$Dst.bak.$timestamp" -Force
      Write-Host "Backed up: $Dst -> $Dst.bak.$timestamp"
    }
  }

  if ($dryRun) {
    Write-Host "DRY_RUN copy: $Src -> $Dst"
  } else {
    Copy-Item -LiteralPath $Src -Destination $Dst -Force
    Write-Host "Copied: $Src -> $Dst"
  }
}

if ($installCodex) {
  Copy-WithBackup -Src (Join-Path $packCodex "AGENTS.md") -Dst (Join-Path $targetHome ".codex/AGENTS.md")
}

if ($installClaude) {
  Copy-WithBackup -Src (Join-Path $packClaude "CLAUDE.md") -Dst (Join-Path $targetHome ".claude/CLAUDE.md")

  $agentDir = Join-Path $packClaude "agents"
  if (Test-Path -LiteralPath $agentDir -PathType Container) {
    Get-ChildItem -LiteralPath $agentDir -Filter "*.md" -File | ForEach-Object {
      Copy-WithBackup -Src $_.FullName -Dst (Join-Path $targetHome ".claude/agents/$($_.Name)")
    }
  }

  $installScript = Join-Path $agentDir "install.sh"
  if (Test-Path -LiteralPath $installScript -PathType Leaf) {
    Copy-WithBackup -Src $installScript -Dst (Join-Path $targetHome ".claude/agents/install.sh")
  }
}

Write-Host ""
Write-Host "DONE: global installation completed"
Write-Host "  HOME=$targetHome"
Write-Host "  CLAUDE=$([int]$installClaude)"
Write-Host "  CODEX=$([int]$installCodex)"
