# claude-config

Personal Claude Code configuration, synced across machines via private git repo.
Cloned to `~/.claude-config` and symlinked into `~/.claude` and `~` so changes
on any machine take effect immediately after `git pull`.

---

## Quick start on a new machine

```bash
git clone https://github.com/KawikaTu/claude-config.git ~/.claude-config
cd ~/.claude-config && ./install.sh
source ~/.zshrc
```

Then manually add secrets not tracked in git (see [Secrets](#secrets)).

---

## What's in this repo

```
~/.claude-config/
├── install.sh              # Bootstrap script — symlinks everything into place
├── zshrc                   # → ~/.zshrc
├── zprofile                # → ~/.zprofile
├── gitconfig               # → ~/.gitconfig
└── claude/
    ├── CLAUDE.md           # → ~/.claude/CLAUDE.md
    ├── settings.json       # → ~/.claude/settings.json
    ├── config-templates/   # → ~/.claude/config-templates/
    ├── hooks/
    │   ├── utils/          # → ~/.claude/hooks/utils/
    │   └── assets/         # → ~/.claude/hooks/assets/ (notification sounds)
    ├── rules/              # → ~/.claude/rules/
    ├── agents/             # → ~/.claude/agents/
    └── skills/             # → ~/.claude/skills/
```

---

## Shell dotfiles

### `zshrc`
Minimal zsh config with Starship prompt. Includes:

- History settings (10k entries, deduplication, shared across sessions)
- Tab completion with case-insensitive matching
- PATH setup for Homebrew, Bun, NVM, PostgreSQL, Java 17, Android SDK
- Tool initialization: Conda, rbenv, mise
- Claude aliases (see below)
- ASCII art startup banner
- Sources `~/.zshrc.local` at the end for machine-specific overrides

**Claude aliases:**

| Alias | Command | Use when |
|---|---|---|
| `cld` | `claude --settings ~/.claude/config-templates/minimal.json` | Quick tasks, exploration |
| `cld-d` | `claude --settings ~/.claude/config-templates/discord.json` | Discord sessions |
| `cld-safe` | `cld --allowedTools 'Read,Glob,Grep'` | Read-only audit mode |

### `zprofile`
Login shell init: Homebrew shellenv + OrbStack shell integration.

### `gitconfig`
Git identity (name + email). Set once, works everywhere.

---

## Claude settings (`claude/settings.json`)

Global Claude Code settings applied to every session:

- **Hooks** — runs Python scripts on two events:
  - `Stop`: plays a notification sound, saves transcript, focuses the terminal
  - `PermissionRequest`: plays a sound when Claude asks for tool approval
- **Enabled plugins** — full plugin set for the default session (see config-templates to use a lighter subset)
- **Always thinking** — extended reasoning enabled
- **Effort level** — set to `medium`

### `claude/CLAUDE.md`
System context injected into every Claude session: machine spec (M4 Pro, 48 GB RAM, uv as package manager).

---

## Config templates (`claude/config-templates/`)

Project-specific `settings.json` files that enable only the plugins a given
project type actually needs. Using a template instead of the default cuts
context window usage by 20–80% by excluding irrelevant plugins.

| Template | Use for | Context savings |
|---|---|---|
| `minimal.json` | Quick tasks, scripts, exploration | ~80% |
| `discord.json` | Discord-integrated sessions | ~80% |
| `python-backend.json` | FastAPI, Django, Flask, uv projects | ~40% |
| `frontend.json` | React, Vue, Bun projects | ~20% |
| `fullstack.json` | Monorepos, full-stack apps | ~10% |
| `documentation.json` | READMEs, writing, presentations | ~70% |

**Using a template:**

```bash
# Option 1: alias (persistent for the session)
cld                        # uses minimal
cld-d                      # uses discord

# Option 2: per-project (committed to the project repo)
cp ~/.claude/config-templates/python-backend.json myproject/.claude/settings.json

# Option 3: one-off
claude --settings ~/.claude/config-templates/frontend.json
```

---

## Hooks (`claude/hooks/utils/`)

Python scripts invoked automatically by Claude Code via `uv run --no-project`.
All use stdlib only — no external dependencies required.

### `on_stop_hook.py`
Runs every time Claude finishes a response:
1. Focuses the originating iTerm2/Terminal tab (brings it to front)
2. Plays `~/.claude/hooks/assets/on_stop_boop.wav` via `afplay`
3. Copies the session transcript to `~/.claude/logs/`

Set `CLAUDE_NO_FOCUS=1` in the environment to skip the window-focus step.

### `on_permission_hook.py`
Runs when Claude requests permission to use a tool — plays a notification sound
so you know to look at the terminal even when it's in the background.

### `focus.py`
Utility imported by the other hooks. Detects the terminal emulator (iTerm2,
Terminal.app, VS Code integrated terminal) and focuses the correct window/tab
using AppleScript or shell escape sequences.

> **Note:** The audio assets (`hooks/assets/*.wav`) are tracked in git and
> symlinked automatically by `install.sh`. The hooks fail silently if a file is
> missing, so you can remove a sound from the assets directory to disable it
> without touching the hook scripts.

---

## Agents (`claude/agents/`)

Custom Claude sub-agents invoked automatically based on task type.

### `security-reviewer.md`
Vulnerability detection specialist. Activated automatically when working with:
- New API endpoints or authentication changes
- User input handling or file uploads
- Database queries or payment code
- Pre-deployment reviews

Reports findings as CRITICAL / HIGH / MEDIUM / LOW with specific remediation.
Follows OWASP Top 10. Zero CRITICAL remaining = completion criteria.

### `curiosity-agent/`
Research companion for essay and document analysis. Works backwards from
source material to original arguments rather than starting with a thesis.
Reads sources like a detective — noticing tensions, contradictions, and
unexpected word choices — then crystallizes them into evidence-backed thesis
directions. Use it when exploring academic papers, primary sources, or any
document-heavy research task.

### `doc-converter/`
Batch document-to-Markdown converter backed by the `essay_miyaki` CLI.
Handles PDF, DOCX, PPTX, XLSX, HTML, images, and more. Use this agent
(rather than the skill) for large batch jobs — 10+ files or full directories.
Runs `--dry-run` first, then reports conversion results.

---

## Skills (`claude/skills/`)

Slash commands that load extended instructions into the current session.

### `/convert-doc`
Converts a single document to Markdown using `essay_miyaki`. For small jobs
(1–9 files). For larger batches, delegates to the `doc-converter` agent.

### `/security-review`
Loads the full security checklist into context — covering secrets management,
input validation, SQL injection, XSS, CSRF, authentication, rate limiting,
and sensitive data exposure. Use before any production deployment or when
adding auth/payment/API features.

---

## Rules (`claude/rules/`)

### `rules/common/security.md`
Mandatory pre-commit security checklist injected into every session:
no hardcoded secrets, validated inputs, parameterized SQL, XSS/CSRF
protection, rate limiting, no sensitive data in error messages.

---

## Secrets

These are **never committed**. Set them up manually on each machine.

### Discord bot token
```bash
mkdir -p ~/.claude/channels/discord
echo 'DISCORD_BOT_TOKEN=your_token_here' > ~/.claude/channels/discord/.env
```

### Machine-local shell overrides
For PATH entries, API keys exported to the shell, or anything
machine-specific that shouldn't be in git:
```bash
# ~/.zshrc.local — not tracked, sourced at the end of .zshrc
export SOME_API_KEY="..."
export PATH="/opt/work-tools/bin:$PATH"
```

---

## Keeping in sync

**After changing any tracked file on this machine:**
```bash
cd ~/.claude-config
git add -p        # review changes interactively
git commit -m "..."
git push
```

**On other machines:**
```bash
cd ~/.claude-config && git pull
# Symlinks mean no re-install needed — changes are live immediately
```

---

## Adding new config

New files in any tracked directory (`agents/`, `skills/`, `rules/`, etc.)
are automatically live on all machines after `git pull` because those
directories are symlinked rather than file-by-file.

To track a new top-level dotfile:
1. Copy it into `~/.claude-config/`
2. Add a `ln -sf` line to `install.sh`
3. Commit and push

---

## Security notes

- The `.gitignore` blocks `.env` files, private keys (`*.pem`, `*.key`, `*.p12`),
  and `*.local` overrides as defense-in-depth — even if accidentally created
  inside this repo, they won't be staged
- `install.sh` will not clobber an existing `~/.gitconfig` that isn't already
  a symlink — it warns and skips instead
- Hook scripts use argument lists (not `shell=True`) so no shell injection
  is possible even if hook input contains unexpected characters
