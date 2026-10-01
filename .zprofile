# Workbrew's setuid /opt/workbrew/bin/brew is currently broken (leaks its
# elevated EUID into the real brew script, which then refuses to run —
# "different real and effective UIDs"). Source shellenv from the real
# Homebrew install instead, but keep workbrew's bin on PATH ahead of it
# so its managed `brew` wrapper is still what gets invoked interactively.
eval "$(/opt/homebrew/bin/brew shellenv)"
# Workbrew's brew is currently fully broken (fails on every command, not just
# shellenv), so it's appended rather than prepended — real Homebrew resolves
# first for the `brew` command until workbrew is fixed/reinstalled.
export PATH="$PATH:/opt/workbrew/bin"

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


# Added by Antigravity CLI installer
export PATH="/Users/elvis/.local/bin:$PATH"
