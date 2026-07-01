#!/usr/bin/env bash
# One-shot installer for athena-reasonix (Linux/macOS; Windows users use install.ps1).
#
#   1. Clones/updates the repo into ~/.reasonix/skills/athena/
#   2. INJECTS (never overwrites) the skill-first discipline block into
#      ~/.reasonix/AGENTS.md — idempotent via begin/end markers
#   3. Warns about other agent tools (codex/gemini) — they read their own dirs,
#      so this does not affect them unless you symlink-share AGENTS.md
#
# Usage:
#   bash install.sh             # install + inject
#   bash install.sh --update    # git pull an existing clone first
#   bash install.sh --no-check  # skip post-install self-check

set -euo pipefail

REPO_URL="https://github.com/Joe-zhouman/athena-reasonix.git"
RX_HOME="${HOME}/.reasonix"
SKILLS_DIR="${RX_HOME}/skills"
TARGET="${SKILLS_DIR}/athena"
AGENTS_FILE="${RX_HOME}/AGENTS.md"

UPDATE=0
RUN_CHECK=1
for arg in "$@"; do
  case "$arg" in
    --update|-u) UPDATE=1 ;;
    --no-check) RUN_CHECK=0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

info() { printf '  \033[36m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m[ok]\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m[!]\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m[x]\033[0m %s\n' "$1" >&2; exit 1; }

echo
echo "=== athena-reasonix installer ==="
printf '  Reasonix home: %s\n' "$RX_HOME"
echo

# --- 0. Reasonix home ---
if [[ ! -d "$RX_HOME" ]]; then
  warn "Reasonix home not found at $RX_HOME"
  printf '      This usually means "reasonix setup" has not been run.\n'
  read -r -p "  Create $RX_HOME anyway? (y/N) " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]] || die "Aborted. Run 'reasonix setup' first, then rerun."
  mkdir -p "$RX_HOME"
  ok "Created $RX_HOME"
else
  ok "Reasonix home exists"
fi

# --- 1. git ---
command -v git >/dev/null 2>&1 || die "git not found on PATH."

# --- 2. clone or update ---
if [[ -d "$TARGET/.git" ]]; then
  info "Existing clone at $TARGET"
  if [[ "$UPDATE" -eq 1 ]]; then
    info "git pull (--update)..."
    git -C "$TARGET" pull --ff-only || warn "pull had conflicts; left as-is."
  else
    ok "Already cloned. Pass --update to git pull."
  fi
else
  info "Cloning into $TARGET ..."
  mkdir -p "$SKILLS_DIR"
  git clone --depth 1 "$REPO_URL" "$TARGET"
  ok "Cloned"
fi

BLOCK_FILE="$TARGET/install/athena-block.md"
[[ -f "$BLOCK_FILE" ]] || BLOCK_FILE="$(cd "$(dirname "$0")" && pwd)/athena-block.md"
[[ -f "$BLOCK_FILE" ]] || die "athena-block.md not found."
BLOCK_CONTENT="$(cat "$BLOCK_FILE")"

# --- 3. INJECT into ~/.reasonix/AGENTS.md (idempotent) ---
BEGIN="<!-- athena-reasonix:begin"
END="athena-reasonix:end -->"
echo
if [[ -f "$AGENTS_FILE" ]]; then
  if grep -qF "$BEGIN" "$AGENTS_FILE"; then
    info "Existing athena block found — replacing with latest."
    # Replace inclusive of begin..end using awk (portable, no GNU sed extensions).
    tmp="$(mktemp)"
    awk -v b="$BEGIN" -v e="$END" -v rep="$BLOCK_FILE" '
      index($0,b) { while((getline line < rep) > 0) print line; skip=1; next }
      index($0,e) { skip=0; next }
      !skip { print }
    ' "$AGENTS_FILE" > "$tmp" && mv "$tmp" "$AGENTS_FILE"
    ok "Updated athena block in $AGENTS_FILE (your other content preserved)"
  else
    info "AGENTS.md exists with your own content — appending athena block."
    printf '\n\n%s\n' "$BLOCK_CONTENT" >> "$AGENTS_FILE"
    ok "Appended athena block to $AGENTS_FILE (your content untouched)"
  fi
else
  info "No AGENTS.md yet — creating one with the athena block."
  printf '%s\n' "$BLOCK_CONTENT" > "$AGENTS_FILE"
  ok "Created $AGENTS_FILE"
fi

# --- 4. cross-tool awareness ---
echo
others=()
for t in .codex .gemini .continue .claude; do
  [[ -d "$HOME/$t" ]] && others+=("~/$t")
done
if [[ ${#others[@]} -gt 0 ]]; then
  warn "Detected other agent tool dirs: ${others[*]}"
  printf '      These tools read their OWN home dirs, so this injection into\n'
  printf '      ~/.reasonix/AGENTS.md does NOT affect them — unless you symlink\n'
  printf '      AGENTS.md across tool dirs. If shared, the skill-first discipline\n'
  printf '      applies everywhere; make sure that is what you want.\n'
fi

echo
ok "Install complete."
printf '  Start a new Reasonix session; the skill-first discipline is now in\n'
printf '  your system prompt. Run /skills to see the 9 guardians + skills.\n'
echo
