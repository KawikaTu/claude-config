# Minimal zsh config with Starship

# ---- History ----
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ---- Completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ---- Key bindings ----
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Paths ----

# Homebrew (macOS ARM, macOS Intel, or Linux)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Bun
[[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# PostgreSQL (Homebrew)
[[ -d /opt/homebrew/opt/postgresql@17/bin ]] && export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Java / Android (only if installed)
if [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
[[ -d "$HOME/Library/Android/sdk" ]] && {
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
}

# ---- Tool initialization ----

# Conda
if [[ -f /opt/anaconda3/bin/conda ]]; then
  eval "$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)" || {
    [[ -f /opt/anaconda3/etc/profile.d/conda.sh ]] && . /opt/anaconda3/etc/profile.d/conda.sh
  }
fi

# rbenv
command -v rbenv &>/dev/null && eval "$(rbenv init - zsh)"

# mise
[[ -x "$HOME/.local/bin/mise" ]] && eval "$("$HOME/.local/bin/mise" activate)"

# ---- Aliases ----
alias cld='claude --settings ~/.claude/config-templates/minimal.json'
alias cld-d='claude --settings ~/.claude/config-templates/discord.json'
alias cld-safe='claude --settings ~/.claude/config-templates/minimal.json --allowedTools '\''Read,Glob,Grep'\'''

# ---- Startup ASCII art ----
# Source: https://patorjk.com/software/taag/#p=display&f=Roman&t=annalog&x=none&v=4&h=4&w=80&we=false
echo
cat << 'EOF'
                                            oooo
                                            `888
 .oooo.   ooo. .oo.   ooo. .oo.    .oooo.    888   .ooooo.   .oooooooo
`P  )88b  `888P"Y88b  `888P"Y88b  `P  )88b   888  d88' `88b 888' `88b
 .oP"888   888   888   888   888   .oP"888   888  888   888 888   888
d8(  888   888   888   888   888  d8(  888   888  888   888 `88bod8P'
`Y888""8o o888o o888o o888o o888o `Y888""8o o888o `Y8bod8P' `8oooooo.
                                                            d"     YD
                                                            "Y88888P'
EOF

# ---- Starship prompt (keep at end) ----
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ---- Machine-local overrides (not tracked in git) ----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
