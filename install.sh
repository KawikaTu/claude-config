#!/bin/bash
# Bootstrap Claude Code config on a new machine
# Usage: cd ~/.claude-config && ./install.sh
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing from $REPO..."

# ── Shell dotfiles ───────────────────────────────────────────────────────────
ln -sf "$REPO/zshrc"    ~/.zshrc
ln -sf "$REPO/zprofile" ~/.zprofile
ln -sf "$REPO/gitconfig" ~/.gitconfig
echo "  ✓ Shell dotfiles symlinked"

# ── Claude dirs ──────────────────────────────────────────────────────────────
mkdir -p ~/.claude

for dir in config-templates hooks/utils rules agents skills; do
  mkdir -p ~/.claude/"$dir"
done

ln -sf "$REPO/claude/CLAUDE.md"          ~/.claude/CLAUDE.md
ln -sf "$REPO/claude/settings.json"      ~/.claude/settings.json
ln -sf "$REPO/claude/config-templates"   ~/.claude/config-templates
ln -sf "$REPO/claude/hooks/utils"        ~/.claude/hooks/utils
ln -sf "$REPO/claude/rules"              ~/.claude/rules
ln -sf "$REPO/claude/agents"             ~/.claude/agents
ln -sf "$REPO/claude/skills"             ~/.claude/skills
echo "  ✓ Claude config symlinked"

# ── Secrets reminder ─────────────────────────────────────────────────────────
if [[ ! -f ~/.claude/channels/discord/.env ]]; then
  echo ""
  echo "  ⚠  Discord bot token not found."
  echo "     Run: mkdir -p ~/.claude/channels/discord"
  echo "          echo 'DISCORD_BOT_TOKEN=your_token' > ~/.claude/channels/discord/.env"
fi

echo ""
echo "Done. Run: source ~/.zshrc"
