#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
  @'
Clone the starter pack to a temporary directory and install project files.

Usage:
  bootstrap-project.ps1 [target-repo] [install-project options]

Examples:
  bootstrap-project.ps1
  bootstrap-project.ps1 . --preserve-progress
  bootstrap-project.ps1 C:\path\to\repo --owner "team-name"

Environment overrides:
  STARTER_PACK_REPO_URL  Git URL to clone (default: official GitHub repo)
  STARTER_PACK_REF       Branch/tag/ref to clone (default: main)
'@ | Write-Host
}

if ($args.Count -gt 0 -and ($args[0] -eq "-h" -or $args[0] -eq "--help")) {
  Show-Usage
  exit 0
}

$targetDir = "."
$argIndex = 0
if ($args.Count -gt 0) {
  $firstArg = [string]$args[0]
  if (-not $firstArg.StartsWith("-")) {
    $targetDir = $firstArg
    $argIndex = 1
  }
}

$installerArgs = @()
if ($argIndex -lt $args.Count) {
  $installerArgs = @($args[$argIndex..($args.Count - 1)])
}

if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
  if ($targetDir -eq "/path/to/your/repo" -or $targetDir -eq "C:\path\to\your\repo") {
    Write-Host "BLOCKED: target directory is still a placeholder: $targetDir"
    Write-Host "Hint: run this command from inside your target repo."
    exit 1
  }
  Write-Host "BLOCKED: target directory does not exist: $targetDir"
  exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "BLOCKED: git is required but not found in PATH."
  exit 1
}

$targetDirResolved = (Resolve-Path -LiteralPath $targetDir).Path
$repoUrl = if (-not [string]::IsNullOrWhiteSpace($env:STARTER_PACK_REPO_URL)) { $env:STARTER_PACK_REPO_URL } else { "https://github.com/PossibLaw/agent-starter-pack.git" }
$repoRef = if (-not [string]::IsNullOrWhiteSpace($env:STARTER_PACK_REF)) { $env:STARTER_PACK_REF } else { "main" }
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-starter-pack-" + [Guid]::NewGuid().ToString("N"))
$cloneDir = Join-Path $tempRoot "repo"

try {
  New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
  & git clone --quiet --depth 1 --branch $repoRef $repoUrl $cloneDir
  if ($LASTEXITCODE -ne 0) {
    throw "git clone failed with exit code $LASTEXITCODE"
  }

  $installerPath = Join-Path $cloneDir "scripts/install-project.ps1"
  if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
    throw "BLOCKED: installer script missing in cloned starter pack."
  }

  & $installerPath $targetDirResolved @installerArgs
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
