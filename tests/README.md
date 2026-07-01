# Windows desktop self-check

After `git pull` on the Reasonix **Windows desktop app**, run the self-check to verify the install loads correctly.

## Quick run

PowerShell (built into Windows 10/11):

```powershell
# from the repo root
powershell -ExecutionPolicy Bypass -File tests\windows-check.ps1
```

If you don't have Node.js installed (and only want to verify skill discovery, not the brainstorming server):

```powershell
powershell -ExecutionPolicy Bypass -File tests\windows-check.ps1 -SkipServer
```

## What it checks

1. **Toolchain** — `node` on PATH (required for brainstorming visual mode); `bash` on PATH (optional — without Git Bash, brainstorming falls back to the `.ps1` launchers).
2. **Guardian + inline skills** — all 9 guardians present with valid frontmatter (`runAs: subagent` + `model: deepseek-*`); a sample of inline skills present.
3. **Brainstorming server round-trip** — `start-server.ps1` actually starts the WebSocket server on Windows, creates a session dir, and `stop-server.ps1` cleans it up. This exercises the Windows path end to end.

## Reading the output

- `[PASS]` green — good.
- `[WARN]` yellow — optional check failed (e.g. no bash). Non-fatal.
- `[FAIL]` red — required check failed. Fix before relying on the install.

Exit code is `0` on success, `1` if any required check failed.

## Why PowerShell, not bash

This repo targets the Reasonix **Windows desktop app** ([README › Platform Support](../README.md#-platform-support--windows-desktop-only)). The desktop app's `shell.prefer` defaults to `auto`, which falls back to **PowerShell** when bash/Git Bash is absent — so the self-check is PowerShell-native to match the worst-case Windows environment.
