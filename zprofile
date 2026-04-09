# Homebrew (macOS ARM, macOS Intel, or Linux)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# OrbStack (macOS only)
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null
