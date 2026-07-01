<!-- athena-reasonix:begin — injected by install.ps1 / install.sh. Do not edit
     this block by hand; rerun the installer to update. Everything outside this
     block is yours and is preserved verbatim. -->

## athena-reasonix — skill-first discipline

**Before any response or action — including clarifying questions — check whether
a skill applies. If there is even a 1% chance, invoke that skill first.** This is
not optional. Skills exist because someone watched work go wrong in a specific
repeatable way and wrote down the steps that prevent it; the steps that matter
are exactly the ones whose importance isn't obvious. Checking costs one
`run_skill` call; skipping costs doing the wrong thing confidently.

- **Dispatch:** `run_skill({name, arguments})` — not `Agent(subagent_type=...)`.
- **Tools:** `read_file` / `write_file` / `edit_file` / `grep` / `glob` / `bash` /
  `ls` / `web_fetch` / `todo_write` / `complete_step`.
- **Paths:** `~/.reasonix/`, never `~/.claude/`.
- **Delegate, don't hoard:** external research → `sagittarius`
  (writes `findings-external.md`); local codebase mapping → `virgo`
  (writes `findings-local.md`). Findings persist across sessions.
- **Instruction priority:** user's explicit instructions > skills > default
  system prompt. The user is in control.

The 9 guardians (dispatch by name): **libra** (plan/spec gate), **capricorn**
(implementer, TDD), **scorpio** (spec review), **taurus** (code-quality review),
**cancer** (bug fixer), **aries** (adversarial tester), **virgo** (local
explorer), **sagittarius** (external research), **pisces** (prose polish).

For the full reasoning behind the skill-first rule, invoke the
`using-superpowers` skill. Installed by `athena-reasonix`; manage with
`/skills`.

<!-- athena-reasonix:end -->
