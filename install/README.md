# Installer

One-shot install for athena-reasonix. Clones the repo into Reasonix's global
skills dir and **injects** (never overwrites) the skill-first discipline into
`~/.reasonix/AGENTS.md`.

## Windows (recommended — the desktop app is the target)

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Flags:
- `-Update` — `git pull` an existing clone before injecting.
- `-NoCheck` — skip the post-install self-check (`tests/windows-check.ps1`).
- `-SkipServer` — run the self-check but skip the brainstorming server round-trip
  (use if Node isn't installed and you don't need visual brainstorming).

## Linux / macOS

```bash
bash install.sh            # install + inject
bash install.sh --update   # git pull first
bash install.sh --no-check # skip self-check
```

## What it does

1. Verifies `~/.reasonix/` exists (offers to create it if not).
2. `git clone --depth 1` into `~/.reasonix/skills/athena/` (or `pull` if present
   and `-Update`).
3. **Injects** the skill-first block into `~/.reasonix/AGENTS.md` — Reasonix's
   global session-start memory, folded into every session's system prompt. The
   block is wrapped in `<!-- athena-reasonix:begin -->` / `:end -->` markers, so
   re-running the installer **updates the block and preserves everything else**
   in your AGENTS.md. It never overwrites your file.

   Three cases it handles:
   - No `AGENTS.md` → creates one with the block.
   - `AGENTS.md` exists, no athena block → appends the block (your content
     untouched).
   - `AGENTS.md` exists with an athena block → replaces the block with the
     latest (your content untouched).

4. Warns if other agent tools (`~/.codex`, `~/.gemini`, `~/.continue`,
   `~/.claude`) are detected. These read **their own** home dirs, so this
   injection does **not** affect them — unless you symlink-share `AGENTS.md`
   across tool dirs, in which case the discipline applies everywhere.
5. Runs `tests/windows-check.ps1` to verify skill discovery + brainstorming
   startup (unless `-NoCheck`).

## Why inject, not copy?

A naive `cp AGENTS.md ~/.reasonix/AGENTS.md` would clobber anything you already
keep there. The installer merges: it looks for its own marked block and only
touches that region. Your notes, other tools' instructions, anything else in
`AGENTS.md` survives verbatim.

## Uninstall

Remove the skills clone and delete the marked block:

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.reasonix\skills\athena"
# then manually delete the <!-- athena-reasonix:begin --> ... :end --> block
# from ~/.reasonix/AGENTS.md
```

(An `uninstall.ps1` is a TODO; for now the markers make manual removal
unambiguous.)
