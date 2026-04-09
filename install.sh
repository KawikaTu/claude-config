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
# - Existing symlink (any target) → re-links in place via ln -sfn
# - Real file/dir                 → warns and skips (never destroys data)
# - Absent                        → creates symlink
symlink() {
  local src="$1" dst="$2"

  if [[ -L "$dst" ]]; then
    ln -sfn "$src" "$dst"
  elif [[ -e "$dst" ]]; then
    echo "  ⚠  skipped: $dst (exists, not a symlink)"
  else
    ln -sn "$src" "$dst"
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
