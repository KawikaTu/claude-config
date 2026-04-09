# claude-config

Private Claude Code configuration, synced across machines via git.

## Bootstrap a new machine

```bash
git clone https://github.com/KawikaTu/claude-config.git ~/.claude-config
cd ~/.claude-config
./install.sh
source ~/.zshrc
```

## Secrets (not in git)

Discord bot token must be created manually on each machine:
```bash
mkdir -p ~/.claude/channels/discord
echo 'DISCORD_BOT_TOKEN=your_token_here' > ~/.claude/channels/discord/.env
```

## Machine-local overrides

For PATH or aliases that differ per machine, create `~/.zshrc.local` (not tracked):
```bash
# Example: work machine has extra PATH
export PATH="/opt/work-tools/bin:$PATH"
```

## Keeping in sync

After changing any tracked file:
```bash
cd ~/.claude-config
git add -p
git commit -m "..."
git push
```

On other machines:
```bash
cd ~/.claude-config && git pull
# Symlinks mean no re-install needed
```

## What's tracked

| Path | Purpose |
|---|---|
| `zshrc` | Shell config, aliases |
| `zprofile` | Login shell (Homebrew, OrbStack) |
| `gitconfig` | Git identity |
| `claude/CLAUDE.md` | System description for Claude |
| `claude/settings.json` | Hooks, plugins, effort settings |
| `claude/config-templates/` | Per-project Claude configs |
| `claude/hooks/utils/` | Notification + focus hooks |
| `claude/rules/` | Security checklist |
| `claude/agents/` | Custom agent definitions |
| `claude/skills/` | Custom skill definitions |
