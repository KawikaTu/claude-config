#!/bin/bash
# Bootstrap Claude Code config on a new machine
# Usage: cd ~/.claude-config && ./install.sh
# Safe to run multiple times — skips already-correct symlinks,
# warns instead of clobbering real files or directories.
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing from $REPO..."

# ── Helpers ──────────────────────────────────────────────────────────────────

# symlink SRC DST
# Creates or updates a symlink at DST pointing to SRC.
# - Already correct symlink → skips (no output)
# - Wrong symlink           → updates silently
# - Real file/dir           → warns and skips (never destroys data)
symlink() {
  local src="$1" dst="$2"

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      return  # already correct, nothing to do
    fi
    ln -sf "$src" "$dst"
    echo "  ↻ updated: $dst"
  elif [[ -e "$dst" ]]; then
    echo "  ⚠  skipped: $dst exists as a real file/directory."
    echo "     Remove it manually to symlink: rm -rf \"$dst\""
  else
    ln -s "$src" "$dst"
    echo "  ✓ linked:  $dst"
  fi
}

# ── Shell dotfiles ───────────────────────────────────────────────────────────

symlink "$REPO/zshrc"    ~/.zshrc
symlink "$REPO/zprofile" ~/.zprofile
symlink "$REPO/gitconfig" ~/.gitconfig

echo ""

# ── Claude config ────────────────────────────────────────────────────────────

# Only create the parents of what we're symlinking — not the targets themselves
mkdir -p ~/.claude ~/.claude/hooks

symlink "$REPO/claude/CLAUDE.md"          ~/.claude/CLAUDE.md
symlink "$REPO/claude/settings.json"      ~/.claude/settings.json
symlink "$REPO/claude/config-templates"   ~/.claude/config-templates
symlink "$REPO/claude/hooks/utils"        ~/.claude/hooks/utils
symlink "$REPO/claude/hooks/assets"       ~/.claude/hooks/assets
symlink "$REPO/claude/rules"              ~/.claude/rules
symlink "$REPO/claude/agents"             ~/.claude/agents
symlink "$REPO/claude/skills"             ~/.claude/skills

echo ""

# ── Secrets reminder ─────────────────────────────────────────────────────────

if [[ ! -f ~/.claude/channels/discord/.env ]]; then
  echo "  ⚠  Discord bot token not found."
  echo "     Run: mkdir -p ~/.claude/channels/discord"
  echo "          echo 'DISCORD_BOT_TOKEN=your_token' > ~/.claude/channels/discord/.env"
  echo ""
fi

echo "Done. Run: source ~/.zshrc"
