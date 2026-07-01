<#
.SYNOPSIS
  athena-reasonix Windows desktop self-check.
  Run this after `git pull` on Windows to verify the install loads correctly.

.DESCRIPTION
  Checks, in order:
    1. node + (bash, if brainstorming visual mode is wanted) are present
    2. all 9 guardian skills + a sample of inline skills exist with valid frontmatter
    3. the brainstorming server actually starts and stops on Windows
       (uses start-server.ps1 / stop-server.ps1 — exercises the Windows path)

  Prints a per-check PASS/FAIL/WARN report and a final summary.
  Exit 0 only if no required (non-optional) check fails.

.NOTES
  Run from anywhere. Auto-detects the repo root (parent of this tests/ dir).
  Requires PowerShell 5.1+ (ships with Windows 10/11) or PowerShell 7.
#>

param(
  [switch]$SkipServer  # skip the brainstorming start/stop round-trip (e.g. no Node)
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SkillsDir = Join-Path $RepoRoot "skills"

$script:pass = 0; $script:fail = 0; $script:warn = 0
function Check {
  param([string]$Name, [bool]$Ok, [string]$Detail = "", [switch]$Optional)
  if ($Ok) {
    Write-Host "  [PASS] $Name" -ForegroundColor Green
    if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkGray }
    $script:pass++
  } elseif ($Optional) {
    Write-Host "  [WARN] $Name" -ForegroundColor Yellow
    if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkGray }
    $script:warn++
  } else {
    Write-Host "  [FAIL] $Name" -ForegroundColor Red
    if ($Detail) { Write-Host "         $Detail" -ForegroundColor DarkGray }
    $script:fail++
  }
}

Write-Host ""
Write-Host "=== athena-reasonix Windows self-check ===" -ForegroundColor Cyan
Write-Host "repo: $RepoRoot"
Write-Host ""

# --- 1. Toolchain ---
Write-Host "[1/3] Toolchain" -ForegroundColor Cyan
$node = Get-Command node -ErrorAction SilentlyContinue
$nodeDetail = if ($node) { $node.Source } else { "Required for brainstorming visual mode. Install from https://nodejs.org" }
Check -Name "node on PATH" -Ok ($null -ne $node) -Detail $nodeDetail -Optional:(-not $SkipServer)

$bash = Get-Command bash -ErrorAction SilentlyContinue
$bashDetail = if ($bash) { $bash.Source } else { "Optional. Without Git Bash, brainstorming uses start-server.ps1 (PowerShell) instead of the .sh scripts." }
Check -Name "bash on PATH" -Ok ($null -ne $bash) -Detail $bashDetail -Optional

# --- 2. Skills present + frontmatter ---
Write-Host ""
Write-Host "[2/3] Guardian + inline skills" -ForegroundColor Cyan
$guardians = "capricorn","scorpio","taurus","libra","cancer","aries","virgo","sagittarius","pisces"
foreach ($g in $guardians) {
  $f = Join-Path $SkillsDir "$g/SKILL.md"
  $exists = Test-Path -LiteralPath $f
  $fmOk = $false
  $detail = ""
  if ($exists) {
    $head = Get-Content -LiteralPath $f -TotalCount 12 -ErrorAction SilentlyContinue
    # Use .Count rather than [bool] cast — robust on PS 5.1 for both single and multi matches.
    $hasRunAs = (@($head | Where-Object { $_ -match '^runAs:\s*subagent' })).Count -gt 0
    $hasModel = (@($head | Where-Object { $_ -match '^model:\s*deepseek-' })).Count -gt 0
    $fmOk = $hasRunAs -and $hasModel
    if (-not $fmOk) { $detail = "frontmatter missing runAs or deepseek- model" }
  } else {
    $detail = "missing $f"
  }
  Check -Name "guardian: $g" -Ok ($exists -and $fmOk) -Detail $detail
}

$inline = "brainstorming","writing-spec","subagent-driven-development","test-driven-development","verification-before-completion"
foreach ($s in $inline) {
  $f = Join-Path $SkillsDir "$s/SKILL.md"
  $exists = Test-Path -LiteralPath $f
  Check -Name "inline skill: $s" -Ok $exists -Detail $(if (-not $exists) { "missing $f" })
}

# --- 3. Brainstorming server round-trip ---
Write-Host ""
Write-Host "[3/3] Brainstorming server (Windows path)" -ForegroundColor Cyan
if (-not $node) {
  Write-Host "  [SKIP] no node on PATH — brainstorming visual mode unavailable. Pass -SkipServer to silence." -ForegroundColor Yellow
} elseif ($SkipServer) {
  Write-Host "  [SKIP] -SkipServer set" -ForegroundColor DarkGray
} else {
  $bs = Join-Path $SkillsDir "brainstorming/scripts"
  $serverStarted = $false
  $sessionDir = $null
  $rawOut = ""
  try {
    # Foreground start-server.ps1 blocks; run it in a job so we can capture stdout
    # and time-bound the wait. start-server.ps1 prints the server-started JSON line.
    $job = Start-Job -ScriptBlock {
      param($p)
      & powershell -ExecutionPolicy Bypass -File "$p\start-server.ps1" 2>&1
    } -ArgumentList $bs

    if ($job | Wait-Job -Timeout 20) {
      $rawOut = ($job | Receive-Job) -join "`n"
    } else {
      $rawOut = ($job | Receive-Job) -join "`n"   # partial output if still running
    }
    $job | Stop-Job -ErrorAction SilentlyContinue
    $job | Remove-Job -Force -ErrorAction SilentlyContinue

    $serverStarted = $rawOut -match '"type"\s*:\s*"server-started"'
    Check -Name "brainstorm server starts (start-server.ps1)" -Ok $serverStarted -Detail ($rawOut -replace '\s+', ' ').Trim()

    if ($serverStarted -and $rawOut -match '"state_dir"\s*:\s*"([^"]+)"') {
      # Literal slash→backslash: use .NET Replace, NOT -replace (which treats the
      # replacement string as regex substitution syntax and chokes on bare '\').
      $stateDir = $matches[1].Replace('/', '\')
      $sessionDir = Split-Path $stateDir -Parent
      $dirExists = [bool](Test-Path -LiteralPath $sessionDir)
      Check -Name "session_dir created" -Ok $dirExists -Detail $sessionDir

      if ($dirExists) {
        & powershell -ExecutionPolicy Bypass -File "$bs\stop-server.ps1" -SessionDir $sessionDir 2>&1 | Out-Null
        $gone = -not (Test-Path -LiteralPath $sessionDir)
        Check -Name "stop-server.ps1 cleans up" -Ok $gone -Detail $(if (-not $gone) { "session dir still present: $sessionDir" })
      }
    } elseif ($serverStarted) {
      Check -Name "session_dir parsed" -Ok $false -Detail "could not parse state_dir from server output"
    }
  } catch {
    Check -Name "brainstorm server round-trip" -Ok $false -Detail $_.Exception.Message
  }
}

# --- Summary ---
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "  PASS: $script:pass   WARN: $script:warn   FAIL: $script:fail"
if ($script:fail -gt 0) {
  Write-Host ""
  Write-Host "Result: FAIL — fix the red items above." -ForegroundColor Red
  exit 1
} else {
  Write-Host ""
  Write-Host "Result: OK — install verified on Windows desktop." -ForegroundColor Green
  exit 0
}
