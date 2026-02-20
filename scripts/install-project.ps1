#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
  @'
Install project-level agent files into a target repository.

Usage:
  install-project.ps1 [target-repo] [options]

Options:
  --name <project_name>
  --owner <team_or_owner>
  --primary "<primary_command>"
  --test "<test_command>"
  --lint "<lint_command>"
  --typecheck "<typecheck_command>"
  --build "<build_command>"
  --preserve-progress   Do not overwrite existing progress files (.agent/*, .claude/history.md)
  --dry-run
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

  $value = [string]$Arguments[$CurrentIndex + 1]
  if ([string]::IsNullOrWhiteSpace($value) -or $value.StartsWith("--")) {
    Write-Host "BLOCKED: missing value for $OptionName"
    Show-Usage
    exit 1
  }

  return $value
}

$targetDir = "."
$index = 0
if ($args.Count -gt 0) {
  $firstArg = [string]$args[0]
  if (-not $firstArg.StartsWith("-")) {
    $targetDir = $firstArg
    $index = 1
  }
}

$projectNameOverride = ""
$teamOrOwnerOverride = ""
$userPrimaryCommand = ""
$userTestCommand = ""
$userLintCommand = ""
$userTypecheckCommand = ""
$userBuildCommand = ""
$dryRun = $false
$preserveProgress = $false

$progressRelativePaths = @(
  ".claude/history.md",
  ".agent/PLAN.md",
  ".agent/CONTEXT.md",
  ".agent/TASKS.md",
  ".agent/REVIEW.md",
  ".agent/TEST.md",
  ".agent/HANDOFF.md",
  ".agent/LEARNINGS.md"
)

while ($index -lt $args.Count) {
  $arg = [string]$args[$index]
  switch ($arg) {
    "--name" {
      $projectNameOverride = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--owner" {
      $teamOrOwnerOverride = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--primary" {
      $userPrimaryCommand = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--test" {
      $userTestCommand = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--lint" {
      $userLintCommand = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--typecheck" {
      $userTypecheckCommand = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--build" {
      $userBuildCommand = Resolve-RequiredOptionValue -OptionName $arg -CurrentIndex $index -Arguments $args
      $index += 2
      continue
    }
    "--preserve-progress" {
      $preserveProgress = $true
      $index += 1
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

if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {
  if ($targetDir -eq "/path/to/your/repo" -or $targetDir -eq "C:\path\to\your\repo") {
    Write-Host "BLOCKED: target directory is still a placeholder: $targetDir"
    Write-Host "Hint: run from inside your target repo with '.' as the target."
    exit 1
  }
  Write-Host "BLOCKED: target directory does not exist: $targetDir"
  Write-Host "Hint: run from inside your target repo with '.' as the target."
  exit 1
}

$targetDirResolved = (Resolve-Path -LiteralPath $targetDir).Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path
$packRoot = Join-Path $repoRoot "packs/project"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path -LiteralPath $packRoot -PathType Container)) {
  Write-Host "BLOCKED: missing project pack: $packRoot"
  exit 1
}

$projectName = if (-not [string]::IsNullOrWhiteSpace($projectNameOverride)) { $projectNameOverride } else { Split-Path -Leaf $targetDirResolved }
$teamOrOwner = if (-not [string]::IsNullOrWhiteSpace($teamOrOwnerOverride)) {
  $teamOrOwnerOverride
} elseif (-not [string]::IsNullOrWhiteSpace($env:USERNAME)) {
  $env:USERNAME
} elseif (-not [string]::IsNullOrWhiteSpace($env:USER)) {
  $env:USER
} else {
  "UNCONFIRMED"
}

$primaryCommand = "UNCONFIRMED"
$testCommand = "UNCONFIRMED"
$lintCommand = "UNCONFIRMED"
$typecheckCommand = "UNCONFIRMED"
$buildCommand = "UNCONFIRMED"
$detectedStack = "UNCONFIRMED"

function Detect-NodePackageManager {
  param([string]$Dir)

  $pkgPath = Join-Path $Dir "package.json"
  if (Test-Path -LiteralPath $pkgPath -PathType Leaf) {
    $pkgContent = Get-Content -LiteralPath $pkgPath -Raw
    if ($pkgContent -match '"packageManager"\s*:\s*"pnpm@') {
      return "pnpm"
    }
    if ($pkgContent -match '"packageManager"\s*:\s*"yarn@') {
      return "yarn"
    }
    if ($pkgContent -match '"packageManager"\s*:\s*"bun@') {
      return "bun"
    }
  }

  if (Test-Path -LiteralPath (Join-Path $Dir "pnpm-lock.yaml") -PathType Leaf) { return "pnpm" }
  if (Test-Path -LiteralPath (Join-Path $Dir "yarn.lock") -PathType Leaf) { return "yarn" }
  if (Test-Path -LiteralPath (Join-Path $Dir "bun.lockb") -PathType Leaf) { return "bun" }
  if (Test-Path -LiteralPath (Join-Path $Dir "bun.lock") -PathType Leaf) { return "bun" }

  return "npm"
}

function Detect-Defaults {
  param([string]$Dir)

  if (Test-Path -LiteralPath (Join-Path $Dir "package.json") -PathType Leaf) {
    $script:detectedStack = "node"
    $pm = Detect-NodePackageManager -Dir $Dir
    switch ($pm) {
      "yarn" {
        $script:primaryCommand = "yarn dev"
        $script:testCommand = "yarn test"
        $script:lintCommand = "yarn lint"
        $script:typecheckCommand = "yarn typecheck"
        $script:buildCommand = "yarn build"
        return
      }
      "bun" {
        $script:primaryCommand = "bun run dev"
        $script:testCommand = "bun test"
        $script:lintCommand = "bun run lint"
        $script:typecheckCommand = "bun run typecheck"
        $script:buildCommand = "bun run build"
        return
      }
      default {
        $script:primaryCommand = "$pm run dev"
        $script:testCommand = "$pm test"
        $script:lintCommand = "$pm run lint"
        $script:typecheckCommand = "$pm run typecheck"
        $script:buildCommand = "$pm run build"
        return
      }
    }
  }

  if (
    (Test-Path -LiteralPath (Join-Path $Dir "pyproject.toml") -PathType Leaf) -or
    (Test-Path -LiteralPath (Join-Path $Dir "requirements.txt") -PathType Leaf) -or
    (Test-Path -LiteralPath (Join-Path $Dir "requirements-dev.txt") -PathType Leaf) -or
    (Test-Path -LiteralPath (Join-Path $Dir "Pipfile") -PathType Leaf)
  ) {
    $script:detectedStack = "python"
    $script:primaryCommand = "UNCONFIRMED"
    $script:testCommand = "pytest -q"
    $script:lintCommand = "ruff check ."
    $script:typecheckCommand = "mypy ."
    $script:buildCommand = "python -m build"
    return
  }

  if (Test-Path -LiteralPath (Join-Path $Dir "go.mod") -PathType Leaf) {
    $script:detectedStack = "go"
    $script:primaryCommand = "go run ."
    $script:testCommand = "go test ./..."
    $script:lintCommand = "golangci-lint run"
    $script:typecheckCommand = "go vet ./..."
    $script:buildCommand = "go build ./..."
    return
  }

  if (Test-Path -LiteralPath (Join-Path $Dir "Cargo.toml") -PathType Leaf) {
    $script:detectedStack = "rust"
    $script:primaryCommand = "cargo run"
    $script:testCommand = "cargo test"
    $script:lintCommand = "cargo clippy --all-targets --all-features -- -D warnings"
    $script:typecheckCommand = "cargo check --all-targets --all-features"
    $script:buildCommand = "cargo build"
    return
  }
}

function Normalize-OrUnconfirmed {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return "UNCONFIRMED"
  }
  return $Value
}

function Is-ProgressRelativePath {
  param([string]$RelativePath)
  return $progressRelativePaths -contains $RelativePath
}

function Copy-WithBackup {
  param(
    [string]$Src,
    [string]$Dst,
    [string]$RelativePath
  )

  if (-not (Test-Path -LiteralPath $Src -PathType Leaf)) {
    Write-Host "BLOCKED: source file missing: $Src"
    exit 1
  }

  $parentDir = Split-Path -Parent $Dst
  if (-not [string]::IsNullOrWhiteSpace($parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
  }

  if ($preserveProgress -and (Test-Path -LiteralPath $Dst) -and (Is-ProgressRelativePath -RelativePath $RelativePath)) {
    if ($dryRun) {
      Write-Host "DRY_RUN preserve: $Dst (existing progress file)"
    } else {
      Write-Host "Preserved: $Dst (existing progress file)"
    }
    return $false
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

  return $true
}

function Replace-Placeholders {
  param([string]$FilePath)

  $content = Get-Content -LiteralPath $FilePath -Raw
  $content = $content.Replace("<PROJECT_NAME>", $projectName)
  $content = $content.Replace("<TEAM_OR_OWNER>", $teamOrOwner)
  $content = $content.Replace("<PRIMARY_COMMAND>", $primaryCommand)
  $content = $content.Replace("<TEST_COMMAND>", $testCommand)
  $content = $content.Replace("<LINT_COMMAND>", $lintCommand)
  $content = $content.Replace("<TYPECHECK_COMMAND>", $typecheckCommand)
  $content = $content.Replace("<BUILD_COMMAND>", $buildCommand)
  Set-Content -LiteralPath $FilePath -Value $content -NoNewline
}

function Ensure-ProgressIgnored {
  $gitignorePath = Join-Path $targetDirResolved ".gitignore"
  $header = "# Local agent continuity files (keep local; do not commit)"
  $added = $false

  if ($dryRun) {
    if (-not (Test-Path -LiteralPath $gitignorePath -PathType Leaf)) {
      Write-Host "DRY_RUN create: $gitignorePath"
    }
    $existingDryRun = if (Test-Path -LiteralPath $gitignorePath -PathType Leaf) {
      @(Get-Content -LiteralPath $gitignorePath)
    } else {
      @()
    }
    if (-not ($existingDryRun -contains $header)) {
      Write-Host "DRY_RUN append: $gitignorePath :: $header"
    }
    foreach ($path in $progressRelativePaths) {
      if (-not ($existingDryRun -contains $path)) {
        Write-Host "DRY_RUN append: $gitignorePath :: $path"
      }
    }
    return
  }

  if (-not (Test-Path -LiteralPath $gitignorePath -PathType Leaf)) {
    New-Item -ItemType File -Path $gitignorePath -Force | Out-Null
    Write-Host "Created: $gitignorePath"
  }

  $existing = @(Get-Content -LiteralPath $gitignorePath)
  if (-not ($existing -contains $header)) {
    if ((Get-Item -LiteralPath $gitignorePath).Length -gt 0) {
      Add-Content -LiteralPath $gitignorePath -Value ""
    }
    Add-Content -LiteralPath $gitignorePath -Value $header
    $added = $true
    $existing = @(Get-Content -LiteralPath $gitignorePath)
  }

  foreach ($path in $progressRelativePaths) {
    if ($existing -contains $path) {
      continue
    }
    Add-Content -LiteralPath $gitignorePath -Value $path
    $added = $true
    $existing += $path
  }

  if ($added) {
    Write-Host "Updated: $gitignorePath (local continuity rules)"
  } else {
    Write-Host "Unchanged: $gitignorePath (local continuity rules already present)"
  }
}

function Warn-IfProgressFilesTracked {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    return
  }

  $null = & git -C $targetDirResolved rev-parse --is-inside-work-tree 2>$null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  $tracked = New-Object System.Collections.Generic.List[string]
  foreach ($path in $progressRelativePaths) {
    $null = & git -C $targetDirResolved ls-files --error-unmatch -- $path 2>$null
    if ($LASTEXITCODE -eq 0) {
      $tracked.Add($path)
    }
  }

  if ($tracked.Count -eq 0) {
    return
  }

  $quoted = $tracked | ForEach-Object { "'$_'" }
  Write-Host ""
  Write-Host "WARNING: local continuity files are tracked in git and can still be committed:"
  foreach ($path in $tracked) {
    Write-Host "  - $path"
  }
  Write-Host "To keep local copies but untrack them, run:"
  Write-Host ("  git -C `"$targetDirResolved`" rm --cached " + ($quoted -join " "))
}

Detect-Defaults -Dir $targetDirResolved

if (-not [string]::IsNullOrWhiteSpace($userPrimaryCommand)) { $primaryCommand = $userPrimaryCommand }
if (-not [string]::IsNullOrWhiteSpace($userTestCommand)) { $testCommand = $userTestCommand }
if (-not [string]::IsNullOrWhiteSpace($userLintCommand)) { $lintCommand = $userLintCommand }
if (-not [string]::IsNullOrWhiteSpace($userTypecheckCommand)) { $typecheckCommand = $userTypecheckCommand }
if (-not [string]::IsNullOrWhiteSpace($userBuildCommand)) { $buildCommand = $userBuildCommand }

$primaryCommand = Normalize-OrUnconfirmed -Value $primaryCommand
$testCommand = Normalize-OrUnconfirmed -Value $testCommand
$lintCommand = Normalize-OrUnconfirmed -Value $lintCommand
$typecheckCommand = Normalize-OrUnconfirmed -Value $typecheckCommand
$buildCommand = Normalize-OrUnconfirmed -Value $buildCommand

$filesToCopy = @(
  @{ Source = "AGENTS.md"; Destination = "AGENTS.md" },
  @{ Source = "CLAUDE.md"; Destination = "CLAUDE.md" },
  @{ Source = ".claude/history.md"; Destination = ".claude/history.md" },
  @{ Source = ".agent/PLAN.md"; Destination = ".agent/PLAN.md" },
  @{ Source = ".agent/CONTEXT.md"; Destination = ".agent/CONTEXT.md" },
  @{ Source = ".agent/TASKS.md"; Destination = ".agent/TASKS.md" },
  @{ Source = ".agent/REVIEW.md"; Destination = ".agent/REVIEW.md" },
  @{ Source = ".agent/TEST.md"; Destination = ".agent/TEST.md" },
  @{ Source = ".agent/HANDOFF.md"; Destination = ".agent/HANDOFF.md" },
  @{ Source = ".agent/LEARNINGS.md"; Destination = ".agent/LEARNINGS.md" }
)

$testTemplatePath = Join-Path $targetDirResolved ".agent/TEST.md"
$testFilePreexisted = Test-Path -LiteralPath $testTemplatePath
$copiedTestTemplate = $false

foreach ($file in $filesToCopy) {
  $wasCopied = Copy-WithBackup -Src (Join-Path $packRoot $file.Source) -Dst (Join-Path $targetDirResolved $file.Destination) -RelativePath $file.Destination
  if ($file.Destination -eq ".agent/TEST.md") {
    $copiedTestTemplate = $wasCopied
  }
}
Ensure-ProgressIgnored

if (-not $dryRun) {
  Replace-Placeholders -FilePath (Join-Path $targetDirResolved "AGENTS.md")
  Replace-Placeholders -FilePath (Join-Path $targetDirResolved "CLAUDE.md")
  if ((-not $preserveProgress) -or (-not $testFilePreexisted) -or $copiedTestTemplate) {
    Replace-Placeholders -FilePath (Join-Path $targetDirResolved ".agent/TEST.md")
  }
}

Write-Host ""
Write-Host "DONE: project files installed into $targetDirResolved"
Write-Host "Resolved values:"
Write-Host "  PRESERVE_PROGRESS=$([int]$preserveProgress)"
Write-Host "  DETECTED_STACK=$detectedStack"
Write-Host "  PROJECT_NAME=$projectName"
Write-Host "  TEAM_OR_OWNER=$teamOrOwner"
Write-Host "  PRIMARY_COMMAND=$primaryCommand"
Write-Host "  TEST_COMMAND=$testCommand"
Write-Host "  LINT_COMMAND=$lintCommand"
Write-Host "  TYPECHECK_COMMAND=$typecheckCommand"
Write-Host "  BUILD_COMMAND=$buildCommand"
Warn-IfProgressFilesTracked

if (
  $primaryCommand -eq "UNCONFIRMED" -or
  $testCommand -eq "UNCONFIRMED" -or
  $lintCommand -eq "UNCONFIRMED" -or
  $typecheckCommand -eq "UNCONFIRMED" -or
  $buildCommand -eq "UNCONFIRMED"
) {
  Write-Host ""
  Write-Host "WARNING: one or more commands are UNCONFIRMED. Update .agent/TEST.md before marking work DONE."
}
