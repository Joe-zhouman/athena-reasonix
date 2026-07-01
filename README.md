# athena-reasonix

<p align="center">
  <strong>English</strong>
  &nbsp;·&nbsp;
  <a href="./README.zh.md">简体中文</a>
  &nbsp;·&nbsp;
  <a href="./docs/UPSTREAM.md">上游项目</a>
</p>

**Athena's Guardians, ported to DeepSeek Reasonix.** Same 9 zodiac-personified subagents, same pain-point-driven philosophy, same grill-me-style brainstorming — running on Reasonix's cache-first harness instead of Claude Code.

> This is the **Reasonix port** of [`athena-guard-superpowers`](https://github.com/Joe-zhouman/athena-guard-superpowers). See [docs/UPSTREAM.md](docs/UPSTREAM.md) for the full lineage. If you use Claude Code, go to the original. If you use Reasonix, you're in the right place.

---

## Why Superpowers on Reasonix?

**DeepSeek models do what you say, not what you mean.**

This is the fundamental asymmetry between DeepSeek and Claude. Claude models are trained to read between the lines — they infer intent, push back on ambiguity, fill in gaps. DeepSeek models execute literally. Give them a vague task and they'll faithfully build the wrong thing, at speed, without ever stopping to say "wait, this doesn't make sense."

Reasonix's killer feature is the prefix cache — 99%+ cache hit rates, 1/5 the token cost of a cold session. It's the cheapest way to run long coding sessions. But that cost advantage is wasted if the model burns cheap tokens building the wrong thing.

**Superpowers is the guardrail layer that DeepSeek needs and Claude doesn't.**

| DeepSeek's tendency | Superpowers countermeasure |
|---|---|
| "Do what you say" — literal, doesn't question | **brainstorming + discuss-first** — force clarification before code |
| Won't suggest alternatives unprompted | **writing-spec** — design rationale must explain *why this over alternatives* |
| Won't catch its own scope creep | **scorpio** — independent spec-compliance review |
| Executes faithfully, skips quality judgment | **taurus** — independent code-quality review |
| Runs fast, breaks fast | **aries** — adversarial runtime testing |
| No intrinsic skepticism | Every gate is an independent agent, not the implementer reviewing itself |

Each skill and guardian is a **manufactured check** where DeepSeek's natural tendencies leave a gap. The point isn't to make DeepSeek behave like Claude — it's to build the guardrails that let DeepSeek's strengths (speed, cost, obedience) operate safely. Obedience is a feature when the instructions are correct; superpowers makes sure the instructions are correct before obedience kicks in.

In short: **Reasonix makes DeepSeek cheap. Superpowers makes DeepSeek safe.**

---

## Why Two Repos?

Claude Code and Reasonix are **different runtimes** — different agent systems, different permission models, different persistence conventions. Porting isn't copy-paste; it's translating concepts:

| Layer | athena-superpowers (Claude Code) | athena-reasonix (Reasonix) |
|---|---|---|
| Agent format | YAML frontmatter with `tools`/`disallowedTools`/`maxTurns` | YAML frontmatter with `runAs: subagent`/`allowed-tools` |
| Model tiers | `fable`/`sonnet`/`haiku` (Claude Code model names) | `deepseek-pro`/`deepseek-flash` (provider-defined in `reasonix.toml`) |
| Agent dispatch | `Agent(subagent_type="capricorn", ...)` | `run_skill({name: "capricorn", arguments: "..."})` |
| Slash commands | `disable-model-invocation: true` | Custom commands in `.reasonix/commands/` |
| Persistence | `docs/superpowers/` (athena convention) | Same convention kept; Reasonix also has `REASONIX.md`/`AGENTS.md` |
| Install | Shell script + symlinks | Clone to `~/.reasonix/skills/athena/` |

**Same philosophy, different runtime.** Both repos share: 9 zodiac guardians, pain-point-driven development, file persistence, independent review gates, and the belief that agents with personality work better.

---

## 🪟 Platform Support — Windows Desktop Only

This repo targets the **Reasonix Windows desktop app**, and only that. Linux, macOS, and the TUI/CLI are **not** supported here — by design, not by neglect.

**Why Windows-only?** Because on every other platform you already have a better option:

| Platform | Use this instead | Reason |
|---|---|---|
| **Linux** | Claude Code TUI | First-class terminal DX; Reasonix's prefix-cache edge matters less on a machine that's always on |
| **macOS** | Claude Code desktop | Native, polished, the reference implementation |
| **Windows** | **athena-reasonix** (this repo) | Reasonix desktop is where DeepSeek's cost advantage + these guardrails actually pay off together — and it's what the people this repo is built for actually run |

Reasonix itself is cross-platform, but this repo only validates against **Windows desktop**. Anything that breaks on Linux/macOS is a known, accepted gap — file an issue only if it also breaks on Windows desktop. Concretely:

- **Brainstorming's visual companion** assumes a Windows shell environment and is not tested under Linux/macOS TUI.
- Install instructions assume a Windows `~/.reasonix/skills/athena/` layout.

If you're on Linux or macOS, you almost certainly want [Claude Code](https://claude.com/claude-code) (or the upstream [`athena-superpowers`](https://github.com/Joe-zhouman/athena-superpowers) for Claude Code) — not this repo.

---

## Architecture

### 9 Guardian Subagents

Each guardian is a Reasonix **subagent skill** (`runAs: subagent`). They run in isolated child loops — tool calls and reasoning never pollute the parent context. Only the final answer returns.

| Guardian | Zodiac | Role | Tier | Auto-invoke? |
|----------|--------|------|------|-------------|
| **capricorn** | 摩羯 | Implementer — TDD, one task at a time | deepseek-pro | Per task |
| **scorpio** | 天蝎 | Spec-compliance reviewer | deepseek-pro | Once per batch |
| **taurus** | 金牛 | Code-quality reviewer | deepseek-pro | After scorpio |
| **libra** | 天秤 | Plan/spec gatekeeper | deepseek-pro | Before implementation |
| **cancer** | 巨蟹 | Bug fixer (repro → root cause → fix) | deepseek-pro | On bug reports |
| **aries** | 白羊 | Adversarial tester — runtime attacks | deepseek-pro | On Aries Gate |
| **virgo** | 处女 | Local codebase explorer (read-only) | deepseek-flash | On demand |
| **sagittarius** | 射手 | External research (web, docs, papers) | deepseek-flash | On demand |
| **pisces** | 双鱼 | Text polish — de-AI-ification + agent readability | deepseek-pro | On demand |

**Model tiers in Reasonix:**
- `deepseek-pro` (≈ Claude Code sonnet/fable tier): capricorn, scorpio, taurus, libra, cancer, aries, pisces
- `deepseek-flash` (≈ Claude Code haiku tier): virgo, sagittarius

These are defaults. Override per-skill via `model:` in frontmatter, or globally via `subagent_models` in `reasonix.toml`.

### Skills (Inline)

Reasonix skills without `runAs: subagent` fold into the parent context (inline). These are the playbooks:

| Skill | Purpose |
|-------|---------|
| **brainstorming** | Grill-me interview → design decisions |
| **writing-spec** | Pain-point-driven spec format |
| **subagent-driven-development** | Dispatch capricorn per task + scorpio/taurus after batch |
| **dispatching-parallel-agents** | Fan out independent work to subagents |
| **systematic-debugging** | Reproducible bug → root cause analysis |
| **using-superpowers** | Skill invocation discipline |
| **verification-before-completion** | Pre-completion checklist |
| **executing-plans** | Plan → task breakdown → execution |
| **writing-plans** | Plan document structure |
| **finishing-a-development-branch** | PR-ready checklist |
| **requesting-code-review** | Code review request format |
| **receiving-code-review** | Code review response format |
| **test-driven-development** | TDD discipline |
| **using-git-worktrees** | Git worktree workflow |

### Complementary Skills (from Matt Pocock)

| Skill | Purpose |
|-------|---------|
| **diagnosing-bugs** | Hard bugs with no clear repro |
| **to-prd** | Conversation → PRD synthesis |
| **prototype** | Throwaway prototype for design questions |

### Slash Commands

Custom commands for manual user invocation only (not auto-triggered by the model):

| Command | Usage |
|---------|-------|
| `/grill-me` | Relentlessly interview your plan/design |
| `/discuss-first` | Talk before coding — clarify intent |
| `/handoff` | Write a handoff doc for the next session |

**Why commands, not skills?** In Claude Code, these three have `disable-model-invocation: true` — they're meant to be invoked by the *user* (`/grill-me`), never by the *model*. Reasonix has no equivalent frontmatter field, but custom commands fill the same role: the model can't auto-trigger a `/command`, only the user can. The body is the same prompt; the wrapper is what enforces "user-only invocation."

---

## Install

### Prerequisites

- **Windows desktop app** — [Reasonix desktop](https://github.com/esengine/DeepSeek-Reasonix) installed on Windows. (Linux/macOS/TUI are unsupported here — see [Platform Support](#-platform-support--windows-desktop-only) above.)
- DeepSeek API key (`DEEPSEEK_API_KEY`)
- `reasonix setup` completed
- **For the brainstorming visual companion only:** Node.js + a bash shell (Git Bash recommended on Windows). The server uses Node built-ins only — no `npm install` needed. If you skip brainstorming's visual mode, you don't need either.

### Install athena-reasonix

```sh
# Clone to Reasonix global skills
git clone https://github.com/Joe-zhouman/athena-reasonix.git ~/.reasonix/skills/athena

# Reasonix auto-discovers skills under convention dirs
```

No install script needed. Reasonix scans `.reasonix/skills/` (among others) for `SKILL.md` files. The repo is self-contained — all skills, commands, and refs live under one directory.

### Verify

```sh
reasonix          # start interactive session
/skills            # list loaded skills — you should see all 9 guardians + skills
/grill-me          # test a slash command
```

---

## ⚠️ Sagittarius Router Is Personalized

Sagittarius's router table and tools reference were built for **Joe's MCP setup** (searxng, context7, z-reader, etc.). Your Reasonix plugins are different.

**The first time you dispatch sagittarius, it will:**
1. Read its current router and tools ref
2. Tell you: "This was built for Joe's MCP setup. Your tools are different. Let me show you what I'd recommend."
3. Walk you through each row — what capability it needs, what tools you actually have, a proposed replacement
4. Let you veto/adjust each row
5. Rewrite the router table and ref only when you agree

Don't blindly accept — review each row. Your tools, your router.

---

## Relationship to athena-superpowers

```
athena-superpowers (Claude Code)          athena-reasonix (Reasonix)
├── .claude-plugin/plugin.json            ├── skills/  (Reasonix auto-discovers)
├── user-agents/  (Claude Code agents)    │   ├── capricorn/SKILL.md  (subagent skill)
│   ├── capricorn.md                      │   ├── scorpio/SKILL.md
│   └── ...                               │   └── ...
├── skills/  (Claude Code skills)         ├── commands/  (Reasonix custom commands)
│   ├── brainstorming/SKILL.md            │   ├── grill-me.md
│   └── ...                               │   └── ...
├── hooks/  (Claude Code hooks)           ├── refs/  (shared with skills)
└── install.sh                            └── README.md
```

Skills bodies are nearly identical — mostly porting changes to frontmatter and tool names. Agent personalities, PHASE flows, and communication rules are preserved.

---

## For Agents

When an agent or subagent reads this repo, here's what it needs to know:

### Key Rules

1. **This is Reasonix, not Claude Code.** Subagents are invoked via `run_skill({name, arguments})`, not `Agent(subagent_type=...)`.
2. **Tools use Reasonix naming.** `read_file` not `Read`; `write_file` not `Write`; `edit_file` not `Edit`; `grep`/`glob`/`bash`/`ls`/`web_fetch`.
3. **No `Agent` tool in subagents.** Guardians can't spawn other guardians. The main agent dispatches.
4. **No `TaskCreate`/`TaskUpdate`/`TaskList`/`TaskGet`.** Reasonix has `todo_write` and `complete_step` instead.
5. **Model tiers are provider-defined.** `deepseek-pro` and `deepseek-flash` are configured in `reasonix.toml`. Users may rename them.
6. **Sagittarius router is personalized.** The tools ref describes MCP tools that may not exist in the user's setup. Walk them through rebuilding it — don't silently overwrite.
7. **findings-local.md / findings-external.md** persist to `docs/superpowers/` (same convention as athena-superpowers).
8. **Slash commands** like `/grill-me` are custom commands in `.reasonix/commands/`, not skills.

### Agent Dispatch Reference

```
Main agent dispatches subagents via run_skill:

run_skill({name: "capricorn",    arguments: "<task description>"})   → implements
run_skill({name: "scorpio",      arguments: "<spec + git range>"})   → reviews spec compliance
run_skill({name: "taurus",       arguments: "<git range>"})          → reviews code quality
run_skill({name: "libra",        arguments: "<plan/spec path>"})     → gates plans
run_skill({name: "cancer",       arguments: "<bug repro>"})          → fixes bugs
run_skill({name: "aries",        arguments: "<target + surfaces>"})  → attacks at runtime
run_skill({name: "virgo",        arguments: "<exploration question>"})→ maps codebase
run_skill({name: "sagittarius",  arguments: "<research question>"})  → hunts knowledge
run_skill({name: "pisces",       arguments: "<text to polish>"})     → polishes prose
```

### Anti-patterns

- Don't clone the whole repo — Reasonix auto-discovers skills from convention dirs.
- Don't put API keys in config files — Reasonix uses `api_key_env`.
- Don't reference `~/.claude/` paths — this is Reasonix; use `~/.reasonix/`.
- Don't use `Agent()` dispatch — Reasonix uses `run_skill()`.

---

## Issues

Found a bug? Have a feature idea? Something doesn't work as expected? **File an issue on this repo.**

If you don't know how to file an issue on GitHub or GitCode — **ask your agent to teach you.** That's literally what it's there for. Type something like "show me how to file an issue about X" and it'll walk you through it.

---

## License

MIT — see [LICENSE](https://github.com/esengine/DeepSeek-Reasonix/blob/master/LICENSE) (inherited from upstream athena-superpowers).
