eval "$(/opt/workbrew/bin/brew shellenv)"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(fnm env --use-on-cd --shell zsh)"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:/Users/elvis/go/bin"

# bun (reflex-bundled). Append, not prepend, so Homebrew's newer bun on PATH wins.
# Reflex still finds its own bun via BUN_INSTALL regardless of PATH order.
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
export PATH="$PATH:$BUN_INSTALL/bin"

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
