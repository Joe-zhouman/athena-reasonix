<#
.SYNOPSIS
  Windows PowerShell launcher for the brainstorm server.
  Equivalent to start-server.sh. Use this when bash/Git Bash is unavailable
  (e.g. Reasonix desktop on Windows with shell.prefer=auto falling back to PowerShell).

  Targets Windows PowerShell 5.1 (ships with Windows 10/11) — no PS7-only syntax.

.PARAMETER ProjectDir
  Store session files under <path>/.superpowers/brainstorm/ instead of the
  OS temp dir. Files persist after the server stops.

.PARAMETER BindHost
  Host/interface to bind (default: 127.0.0.1).
  Use 0.0.0.0 in remote/containerized environments.

.PARAMETER UrlHost
  Hostname shown in the returned URL JSON.

.PARAMETER Background
  Detached background launch. NOT supported in foreground-only desktop shells;
  the script will report an error if requested. Use foreground (the default),
  which is also the reliable mode on Windows desktop.
#>

param(
  [string]$ProjectDir = "",
  [string]$BindHost = "127.0.0.1",
  [string]$UrlHost = "",
  [switch]$Background
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

if (-not $UrlHost) {
  if ($BindHost -eq "127.0.0.1" -or $BindHost -eq "localhost") {
    $UrlHost = "localhost"
  } else {
    $UrlHost = $BindHost
  }
}

# Cross-platform session dir (mirrors start-server.sh logic).
# [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() is .NET, works in PS 5.1.
$stamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
if ($ProjectDir -ne "") {
  $SessionDir = Join-Path $ProjectDir ".superpowers\brainstorm\$PID-$stamp"
} else {
  $SessionDir = Join-Path ([System.IO.Path]::GetTempPath()) "brainstorm-$PID-$stamp"
}
$StateDir = Join-Path $SessionDir "state"
$ContentDir = Join-Path $SessionDir "content"
$LogFile = Join-Path $StateDir "server.log"
$PidFile = Join-Path $StateDir "server.pid"

New-Item -ItemType Directory -Force -Path $ContentDir, $StateDir | Out-Null

# Harness PID (best-effort on Windows; PowerShell has no portable getppid).
$OwnerPid = $PID

$env:BRAINSTORM_DIR = $SessionDir
$env:BRAINSTORM_HOST = $BindHost
$env:BRAINSTORM_URL_HOST = $UrlHost
$env:BRAINSTORM_OWNER_PID = "$OwnerPid"

# Locate node. Reasonix bundles a Go binary, not Node — node must be on PATH.
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($null -eq $nodeCmd) {
  @{ error = "node not found on PATH. The brainstorm server needs Node.js installed separately from Reasonix." } | ConvertTo-Json -Compress
  exit 1
}

if ($Background) {
  # PowerShell Start-Job runs in a *separate* powershell.exe whose Id is NOT the
  # node process PID, so stop-server.ps1 (which signals by PID) cannot reliably
  # target it. Rather than ship a silently-broken background mode, report clearly.
  @{ error = "Background mode is not supported in start-server.ps1. Run in the foreground (the default) — it is the reliable mode on Windows desktop. If you need the server to outlive the tool call, launch the foreground command from a shell you keep open." } | ConvertTo-Json -Compress
  exit 1
}

# Foreground: the recommended mode on Windows desktop.
# Write the PID of THIS powershell process; the node child inherits lifetime from it.
"$PID" | Out-File -FilePath $PidFile -Encoding ascii
# server.cjs prints the server-started JSON line to stdout; it flows straight through.
try {
  & node "server.cjs"
} finally {
  Remove-Item -LiteralPath $PidFile -ErrorAction SilentlyContinue
}
