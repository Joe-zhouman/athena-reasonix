# sagittarius — Tool call guide (Reasonix)

The concrete "which tool, which args" for each research shape. sagittarius's body carries the *router* (question type → capability needed); this file carries the *tool calls* for the capabilities.

**Read this after PHASE 1 routes the question**, before you start hunting. The toolset grows over time — when a new MCP server or tool arrives, add it under the capability it serves; don't rewrite the router in body.

---

## Built-in tools (always available)

| Tool | Purpose |
|------|---------|
| `web_fetch` | Fetch a URL and return content. Primary external research tool. |
| `read_file` | Read a local file. |
| `grep` | Search code/content with regex. |
| `glob` | Find files by name pattern. |
| `bash` | Run shell commands (git clone, curl, etc.). |
| `ls` | List directory contents. |

## MCP tools (optional — depends on user's `[[plugins]]` config)

The router speaks in *capabilities*, not tool names. When a capability needs an MCP tool the user hasn't configured, fall back to built-in alternatives.

| Capability | MCP tool (if configured) | Built-in fallback |
|------------|--------------------------|-------------------|
| Library docs (version-pinned, authoritative) | `mcp__doc__context7-query-docs` + `mcp__doc__context7-resolve-library-id` | `web_fetch` official docs URL, or `bash` clone repo and read docs |
| Web search (multi-engine) | `mcp__common__vps-searxng_search` or similar search MCP | `web_fetch` known doc/search URLs directly |
| Read a URL (LLM-friendly markdown) | `mcp__common__z-webReader` or similar reader MCP | `web_fetch` (built-in) |
| Read a file in a GitHub repo (no clone) | `mcp__common__z-read_file` | `bash` clone + `read_file` |
| Map a GitHub repo structure | `mcp__common__z-get_repo_structure` | `bash` clone + `ls` |
| Search a repo's docs/issues | `mcp__common__z-search_doc` | `bash` clone + `grep` |

**Rule**: try the MCP tool first if available; fall back to built-ins if not configured. Never assume an MCP tool exists — check what's actually in your tool list before calling it.

---

## URL fetch ordering

`web_fetch` is the built-in. If the user has configured MCP readers (like `mcp__common__z-webReader`), prefer them for better markdown conversion. If a fetch tool errors or returns thin content, switch tool rather than retry.

---

## Per-capability call patterns

### Library docs

**If `mcp__doc` (context7) is configured:**
1. `mcp__doc__context7-resolve-library-id` → get library ID
2. `mcp__doc__context7-query-docs` → query the docs

**Otherwise (built-in fallback):**
1. `web_fetch` the official docs URL for the library
2. If that fails, `bash` clone the repo and `read_file` / `grep` the docs

### Web search

**If search MCP (e.g. searxng) is configured:**
```
mcp__common__vps-searxng_search  query: "<question>"  num_results: 10
```

**Otherwise (built-in fallback):**
- `web_fetch` known doc/search URLs directly
- `bash` + `curl` for API-based searches if applicable

### Read a specific URL

**Preferred**: `mcp__common__z-webReader` (better markdown conversion) if configured.
**Fallback**: `web_fetch` (built-in). Accepts a URL, returns content as markdown.

### Read a file in a GitHub repo (no clone)

**If `mcp__common__z-read_file` is configured:**
```
repo_name: "owner/repo"
file_path: "path/to/file"
```

**Otherwise**: `bash` clone the repo (`git clone --depth 1`) then `read_file`.

### Map a repo before reading

**If `mcp__common__z-get_repo_structure` is configured**: use it to get the tree.

**Otherwise**: `bash` clone then `ls` / `find`.

### Go deep on source — `bash` clone

```
git clone --depth 1 https://github.com/owner/repo.git "${TMPDIR:-/tmp}/name"
cd "${TMPDIR:-/tmp}/name"
# then grep for patterns, read_file key files, git blame for history
```

Always cite a permalink:
```
https://github.com/<owner>/<repo>/blob/<sha>/<filepath>#L<start>-L<end>
```
Get SHA: `git rev-parse HEAD`

---

## Choosing between overlapping tools

- **MCP read_file vs clone**: one file → MCP (no clone overhead); multiple files / grep / blame → clone.
- **MCP search_doc vs clone**: "does the repo mention X" → MCP search_doc (fast); "how is X implemented across files" → clone.
- **MCP webReader vs web_fetch**: webReader first (better markdown) if configured; web_fetch as fallback.
- **MCP context7 vs web_fetch for a library**: context7 first (version-pinned, authoritative); web_fetch official docs if not configured.
