<#
.SYNOPSIS
  Windows PowerShell companion to stop-server.sh. Stops the brainstorm server
  (best-effort) and cleans up its temp session dir.

  Targets Windows PowerShell 5.1 — no PS7-only syntax.

.PARAMETER SessionDir
  The session_dir returned by start-server.ps1 (the BRAINSTORM_DIR value).

.DESIGN
  Two jobs, in this order:
    1. Stop the server process — best-effort. The PID file (written by
       start-server.ps1) holds the launcher's PID. In foreground mode the
       launcher may already have exited by the time we run, so a missing
       PID file or a dead PID is normal, not an error. We only signal a
       process that is actually node, to avoid killing an unrelated process
       that reused the PID (parity with stop-server.sh pid_is_ours).
    2. Clean up the session dir — the main job. We delete it only if it
       lives under the OS temp path. Persistent dirs (.superpowers/brainstorm/)
       are kept so mockups survive for review.
#>

param(
  [Parameter(Mandatory=$true)]
  [string]$SessionDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SessionDir)) {
  @{ status = "not_running" } | ConvertTo-Json -Compress
  exit 0
}

$StateDir = Join-Path $SessionDir "state"
$PidFile = Join-Path $StateDir "server.pid"

# --- 1. Best-effort process stop ---
$signaledSomething = $false
$pidVal = 0
if (Test-Path -LiteralPath $PidFile) {
  $pidLine = (Get-Content -LiteralPath $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  if ($pidLine -match '^\d+$') {
    $pidVal = [int]$pidLine
    $proc = $null
    try { $proc = Get-Process -Id $pidVal -ErrorAction Stop } catch {}
    if ($null -ne $proc) {
      # Only signal if it looks like our server stack: node, or the powershell/
      # pwsh launcher that hosts node in foreground mode.
      if ($proc.ProcessName -match '^(node|powershell|pwsh)$') {
        try {
          # Kill the whole process tree rooted at the launcher: this brings down
          # the node child too. tree-kill via Stop-Process on descendants is not
          # built into PS 5.1, so kill the launcher and rely on it taking node
          # with it (the common foreground case).
          Stop-Process -Id $pidVal -Force -ErrorAction SilentlyContinue
          Start-Sleep -Milliseconds 300
          $signaledSomething = $true
        } catch {}
      }
    }
  }
  Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
}
# Note: we intentionally do NOT scan all node.exe processes by command line here
# (Get-CimInstance Win32_Process is slow/unreliable on some Windows hosts and can
# hang for tens of seconds). If a node child survives its launcher, the OS temp
# dir is still cleaned below; the orphaned node will exit when its socket closes.

Remove-Item -LiteralPath (Join-Path $StateDir "server.log") -Force -ErrorAction SilentlyContinue

# --- 2. Clean up the session dir if it's under the OS temp path ---
$tempRoot = [System.IO.Path]::GetTempPath()
$resolvedSession = $SessionDir
$resolvedTemp = $tempRoot
try { $resolvedSession = [System.IO.Path]::GetFullPath($SessionDir) } catch {}
try { $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot) } catch {}

if ($resolvedSession.StartsWith($resolvedTemp, [StringComparison]::OrdinalIgnoreCase)) {
  Remove-Item -LiteralPath $resolvedSession -Recurse -Force -ErrorAction SilentlyContinue
  $gone = -not (Test-Path -LiteralPath $resolvedSession)
  if ($gone) {
    @{ status = "stopped" } | ConvertTo-Json -Compress
  } else {
    @{ status = "stopped"; cleanup = "partial (some files locked — dir remains at $resolvedSession)" } | ConvertTo-Json -Compress
  }
} else {
  @{ status = "stopped"; cleanup = "skipped (session dir not under OS temp — persistent mockups kept)" } | ConvertTo-Json -Compress
}
