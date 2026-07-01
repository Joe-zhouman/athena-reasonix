<#
.SYNOPSIS
  One-shot installer for athena-reasonix on Windows desktop.
  Targets Windows PowerShell 5.1 — no PS7-only syntax.

.DESCRIPTION
  1. Checks Reasonix home (~/.reasonix) exists; offers to create it.
  2. Clones/updates the repo into ~/.reasonix/skills/athena/.
  3. INJECTS (never overwrites) the skill-first discipline block into
     ~/.reasonix/AGENTS.md — Reasonix's global session-start memory. Idempotent:
     re-running updates the marked block, leaves the rest of your file alone.
  4. Warns if other agent tools (codex/gemini) are present — they read their
     OWN home dirs, so this injection does not affect them unless you symlink
     share AGENTS.md across tools.
  5. Optionally runs tests/windows-check.ps1 to verify.

.PARAMETER SkipServer
  Skip the brainstorming server round-trip in the post-install check.
.PARAMETER NoCheck
  Skip the post-install self-check entirely.
.PARAMETER Update
  Force a git pull on an existing clone (default: pull if already cloned).
#>

param(
  [switch]$SkipServer,
  [switch]$NoCheck,
  [switch]$Update
)

$ErrorActionPreference = "Stop"
function Info($m){ Write-Host "  $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  [!]  $m" -ForegroundColor Yellow }
function Die($m){ Write-Host "  [x]  $m" -ForegroundColor Red; exit 1 }

# Run git without PS treating git's stderr (it writes progress to stderr) as a
# terminating error under EAP=Stop. We drop EAP for the call and discard git's
# stderr noise (progress bars); success is judged by the exit code, not stderr.
function Invoke-Git {
  param([Parameter(Mandatory=$true)][string[]]$GitArgs)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    & git @GitArgs 2>$null | Out-Host
  } finally {
    $ErrorActionPreference = $prev
  }
  return $LASTEXITCODE
}

$RepoURL = "https://github.com/Joe-zhouman/athena-reasonix.git"
$Home_ = $HOME
$RxHome = Join-Path $Home_ ".reasonix"
$SkillsDir = Join-Path $RxHome "skills"
$Target = Join-Path $SkillsDir "athena"
$AgentsFile = Join-Path $RxHome "AGENTS.md"

Write-Host ""
Write-Host "=== athena-reasonix installer ===" -ForegroundColor Cyan
Write-Host "  Reasonix home: $RxHome"
Write-Host ""

# --- 0. Reasonix home ---
if (-not (Test-Path -LiteralPath $RxHome)) {
  Warn "Reasonix home not found at $RxHome"
  Write-Host "      This usually means 'reasonix setup' hasn't been run." -ForegroundColor DarkGray
  $ans = Read-Host "  Create $RxHome anyway? (y/N)"
  if ($ans -ne "y" -and $ans -ne "Y") { Die "Aborted. Run 'reasonix setup' first, then rerun this installer." }
  New-Item -ItemType Directory -Force -Path $RxHome | Out-Null
  Ok "Created $RxHome"
} else {
  Ok "Reasonix home exists"
}

# --- 1. git available? ---
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { Die "git not found on PATH. Install Git (https://git-scm.com) and rerun." }

# --- 2. clone or update the repo ---
if (Test-Path -LiteralPath (Join-Path $Target ".git")) {
  Info "Existing clone at $Target"
  if ($Update) {
    Info "git pull (forced by -Update)..."
    $rc = Invoke-Git @("-C", $Target, "pull", "--ff-only")
    if ($rc -ne 0) { Warn "pull had conflicts (exit $rc); left as-is. Resolve manually in $Target" }
  } else {
    Ok "Already cloned. Pass -Update to git pull."
  }
} else {
  Info "Cloning into $Target ..."
  New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
  $rc = Invoke-Git @("clone", "--depth", "1", $RepoURL, $Target)
  if ($rc -ne 0) { Die "git clone failed (exit $rc)." }
  Ok "Cloned"
}

# locate the block source (shipped with the repo, or sibling of this script)
$BlockFile = Join-Path $Target "install\athena-block.md"
if (-not (Test-Path -LiteralPath $BlockFile)) {
  $BlockFile = Join-Path $PSScriptRoot "athena-block.md"
}
if (-not (Test-Path -LiteralPath $BlockFile)) { Die "athena-block.md not found (looked in repo and script dir)." }
$BlockContent = (Get-Content -LiteralPath $BlockFile -Raw -Encoding UTF8).TrimEnd()

# --- 3. INJECT the block into ~/.reasonix/AGENTS.md (idempotent) ---
# Merge boundary is the <athena reasonix> ... </athena> tag pair. The opening
# tag may carry attributes, so match "<athena" up to the first ">" on that line,
# and the literal "</athena>" closer.
$BeginMarker = "<athena"
$EndMarker = "</athena>"

Write-Host ""
if (Test-Path -LiteralPath $AgentsFile) {
  $existing = Get-Content -LiteralPath $AgentsFile -Raw -Encoding UTF8
  if ($existing -match "<athena[^>]*>") {
    # Replace the existing block (opening tag through </athena>, inclusive).
    Info "Existing <athena> block found in AGENTS.md — replacing with latest."
    # Replace the region from the opening <athena ...> tag through the literal
    # </athena> closer. Done with string indexing (not a regex MatchEvaluator)
    # so the new content is inserted verbatim — no $ backref expansion — and it
    # works on PowerShell 5.1 (no ScriptBlock-as-delegate needed).
    $beginIdx = $existing.IndexOf("<athena")
    $endIdx = $existing.IndexOf("</athena>")
    if ($beginIdx -ge 0 -and $endIdx -gt $beginIdx) {
      $after = $endIdx + "</athena>".Length
      $newContent = $existing.Substring(0, $beginIdx) + $BlockContent + $existing.Substring($after)
      Set-Content -LiteralPath $AgentsFile -Value $newContent -NoNewline -Encoding UTF8
      Ok "Updated <athena> block in $AgentsFile (your other content preserved)"
    } else {
      Warn "Markers looked present but couldn't be located cleanly; appending instead."
      Add-Content -LiteralPath $AgentsFile -Value ("`n`n" + $BlockContent) -Encoding UTF8
    }
  } else {
    # File exists, no athena block yet — append.
    Info "AGENTS.md exists with your own content — appending <athena> block."
    $sep = "`n`n"
    if ($existing -match "\n$") { $sep = "`n" }
    Add-Content -LiteralPath $AgentsFile -Value ($sep + $BlockContent) -Encoding UTF8
    Ok "Appended <athena> block to $AgentsFile (your content untouched)"
  }
} else {
  Info "No AGENTS.md yet — creating one with the <athena> block."
  Set-Content -LiteralPath $AgentsFile -Value $BlockContent -NoNewline -Encoding UTF8
  Ok "Created $AgentsFile"
}

# --- 4. cross-tool awareness ---
Write-Host ""
$otherTools = @()
foreach ($t in @("~/.codex","~/.gemini","~/.continue","~/.claude")) {
  $p = Join-Path $Home_ ($t -replace '^~/','')
  if (Test-Path -LiteralPath $p) { $otherTools += $t }
}
if ($otherTools.Count -gt 0) {
  Warn "Detected other agent tool dirs: $($otherTools -join ', ')"
  Write-Host "      These tools read their OWN home dirs, so this injection into" -ForegroundColor DarkGray
  Write-Host "      ~/.reasonix/AGENTS.md does NOT affect them — unless you symlink" -ForegroundColor DarkGray
  Write-Host "      AGENTS.md across tool dirs. If you share it, the skill-first" -ForegroundColor DarkGray
  Write-Host "      discipline will apply everywhere; make sure that's what you want." -ForegroundColor DarkGray
}

# --- 5. optional self-check ---
Write-Host ""
if ($NoCheck) {
  Ok "Done (skipped self-check via -NoCheck)."
} else {
  $check = Join-Path $Target "tests\windows-check.ps1"
  if (Test-Path -LiteralPath $check) {
    Info "Running self-check (tests/windows-check.ps1)..."
    $ckArgs = @("-ExecutionPolicy","Bypass","-File",$check)
    if ($SkipServer) { $ckArgs += "-SkipServer" }
    $prev = $ErrorActionPreference; $ErrorActionPreference = "Continue"
    try { & powershell @ckArgs } finally { $ErrorActionPreference = $prev }
    if ($LASTEXITCODE -ne 0) {
      Warn "Self-check reported failures. See output above; the install itself succeeded."
    }
  } else {
    Ok "Done. (self-check script not found in this checkout)"
  }
}

Write-Host ""
Ok "Install complete."
Write-Host "  Start a new Reasonix session; the skill-first discipline is now in" -ForegroundColor DarkGray
Write-Host "  your system prompt. Run /skills to see the 9 guardians + skills." -ForegroundColor DarkGray
Write-Host ""
Warn "One more thing — sagittarius's router is personalized to Joe's MCP setup."
Write-Host "  Before your first sagittarius dispatch, migrate its router to YOUR tools:" -ForegroundColor DarkGray
Write-Host "  edit ~/.reasonix/skills/athena/refs/sagittarius-tools.md and the router" -ForegroundColor DarkGray
Write-Host "  table in skills/sagittarius/SKILL.md (left columns are 'capabilities' and" -ForegroundColor DarkGray
Write-Host "  stay; only the tool names change). Or ask the agent to walk you through it." -ForegroundColor DarkGray
Write-Host "  See README 'Sagittarius Router Is Personalized' for details." -ForegroundColor DarkGray
Write-Host ""
