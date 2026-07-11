# Changelog

All notable changes to **athena-reasonix** are recorded here.
This is the Reasonix (DeepSeek) port of [athena-guard-superpowers](https://github.com/Joe-zhouman/athena-guard-superpowers).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

> **Note on versioning:** reasonix has no `plugin.json`; the version lives only in git tags. Version numbers intentionally track the superpowers release they were synced from (v0.2.0 here = "synced up to superpowers v0.2.0"). Most prior history is "sync from superpowers" and is not retroactively enumerated — superpowers' CHANGELOG is the source of truth for the underlying changes.

---

## [0.2.0] — 2026-07-11

Synced up to [athena-guard-superpowers v0.2.0](https://github.com/Joe-zhouman/athena-guard-superpowers/releases/tag/v0.2.0). The headline change is the sagittarius QUICK/DEEP redesign.

### Changed
- **sagittarius split into QUICK / DEEP tiers.** Was running its full multi-source research pipeline on every dispatch (a one-line lookup took half an hour). Skill body slimmed to persona + self-router only (zero execution flow); two self-contained mode refs (`refs/sagittarius-quick.md`, `refs/sagittarius-deep.md`), agent reads only the one it needs. Adapted to reasonix's tool surface: `web_fetch` as the built-in, `context7` / `searxng` MCPs as optional. Model-neutral (no `haiku` references — reasonix runs `deepseek-flash`).
- **Dispatch instructions now tag the tier.** `brainstorming` and `using-superpowers` tell the main agent to lead the `run_skill({name: "sagittarius", ...})` call with `Tier: quick` or `Tier: deep` so sagittarius self-routes immediately. Default to `quick` when unsure.

### Not applicable (deliberately not ported from superpowers v0.2.0)
- **session-start hash-pin guard** — superpowers added then removed this; reasonix has no `session-start` hook, so there was nothing to add or remove.
- **Global "Explore findings → persist" rule** — that lives in the user's global `~/.claude/CLAUDE.md`, not in any repo; nothing to port.

---

### History

This project is the Reasonix port of athena-guard-superpowers, which itself forks [obra/superpowers](https://github.com/obra/superpowers) (~5.0.x era). For the full history of the underlying changes, see those repositories. reasonix's own history prior to v0.2.0 is a series of syncs from superpowers and is not enumerated here.
