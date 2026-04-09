# Claude Code Configuration Templates

Minimal configuration templates for different project types to optimize context window usage.

## Available Templates

### 1. **python-backend.json**
For Python backend projects using uv, Pydantic, and Pytest.

**Enabled plugins:**
- ✅ Context7 (documentation lookup)
- ✅ Security Compliance (backend security)
- ✅ Feature Dev (code development)
- ✅ Serena (semantic code editing)
- ✅ Supabase (database operations)

**Disabled plugins:**
- ❌ Frontend Design
- ❌ Playwright
- ❌ ARM Cortex
- ❌ Document Skills

---

### 2. **frontend.json**
For frontend projects using Bun and modern web frameworks.

**Enabled plugins:**
- ✅ Context7 (library docs)
- ✅ Frontend Design (UI components)
- ✅ Playwright (browser testing)
- ✅ Security Compliance (XSS, security)
- ✅ Feature Dev
- ✅ Serena
- ✅ Supabase (database operations)

**Disabled plugins:**
- ❌ ARM Cortex
- ❌ Document Skills

---

### 3. **fullstack.json**
For full-stack projects with both frontend and backend.

**Enabled plugins:**
- ✅ All development-related plugins (including Supabase)
- ✅ Document Skills (READMEs, docs alongside code)
- ❌ Only ARM Cortex disabled

---

### 4. **documentation.json**
For documentation, writing, and non-code projects.

**Enabled plugins:**
- ✅ Serena (for editing docs in repos)
- ✅ Document Skills (presentations, PDFs, etc.)

**Disabled plugins:**
- ❌ All development tools (including Supabase)

---

### 5. **minimal.json**
Ultra-lightweight for quick tasks, exploration, or minimal context usage.

**Enabled plugins:**
- ✅ Serena only

**Disabled plugins:**
- ❌ Everything else (including Supabase)

---

### 6. **discord.json**
Like minimal, but with the Discord plugin enabled. Use via the `cld-d` alias when starting a session that needs to send/receive Discord messages.

**Enabled plugins:**
- ✅ Serena
- ✅ Discord

**Disabled plugins:**
- ❌ Everything else (including Supabase)

---

## Usage

### Option 1: Copy to Project (Recommended)

```bash
# Navigate to your project
cd ~/projects/my-backend-app

# Create .claude directory if it doesn't exist
mkdir -p .claude

# Copy appropriate template
cp ~/.claude/config-templates/python-backend.json .claude/settings.json
```

Now every time you run `claude` in that project, it will use the minimal config.

---

### Option 2: Use as Reference

Copy the JSON content from a template and paste it into your project's `.claude/settings.json`.

---

### Option 3: Personal Override

For personal preferences that shouldn't be committed to git:

```bash
# Copy to local settings (gitignored)
cp ~/.claude/config-templates/minimal.json ~/projects/my-app/.claude/settings.local.json
```

---

## Template Customization

Feel free to edit these templates to match your workflow:

```json
{
  "enabledPlugins": {
    "plugin-name@marketplace": true,  // Enable
    "another-plugin@marketplace": false  // Disable
  }
}
```

---

## Quick Reference Table

| Project Type | Template | Context Savings | Use Case |
|--------------|----------|-----------------|----------|
| Python API/Backend | `python-backend.json` | ~40% | FastAPI, Django, Flask projects |
| React/Vue/Web | `frontend.json` | ~20% | Frontend-only projects |
| Full-stack app | `fullstack.json` | ~10% | Monorepos, full-stack apps |
| Docs/Writing | `documentation.json` | ~70% | READMEs, presentations, reports |
| Quick tasks | `minimal.json` | ~80% | Exploration, simple scripts |
| Discord sessions | `discord.json` | ~80% | Responding to Discord messages |

---

## Advanced: CLI Override

You can also use these templates without copying them:

```bash
# Start Claude with a specific template
cd ~/projects/my-app
claude --settings ~/.claude/config-templates/minimal.json

# Or use the shell aliases (defined in ~/.zshrc):
# cld      → minimal (Serena only)
# cld-d    → discord (Serena + Discord)
# cld-safe → minimal, read-only tools only

# Or combine with setting sources
claude --setting-sources user --settings ~/.claude/config-templates/python-backend.json
```

---

## Tips

1. **Start minimal, add as needed**: Use `minimal.json` and enable plugins only when required
2. **Commit project settings**: Add `.claude/settings.json` to git so team members get the same config
3. **Use local overrides**: Create `.claude/settings.local.json` for personal preferences
4. **Check active plugins**: Run `claude --version` or check session startup to see loaded plugins

---

## Created Templates

- ✅ `python-backend.json` - Python/uv/Pydantic projects
- ✅ `frontend.json` - Bun/React/Vue projects
- ✅ `fullstack.json` - Full-stack applications
- ✅ `documentation.json` - Writing and docs
- ✅ `minimal.json` - Ultra-lightweight sessions
- ✅ `discord.json` - Minimal + Discord plugin
