GIT_EDITOR=vim
GITHUB_EDITOR=vim
EDITOR=vim
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

[ -f "$HOME/.env.local" ] && source "$HOME/.env.local"

# Load API keys from macOS Keychain for new shells.
# Add once with:
# security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w "sk-..."
# security add-generic-password -U -a "$USER" -s ANTHROPIC_API_KEY -w "sk-ant-..."
if command -v security >/dev/null 2>&1; then

#   OPENAI_API_KEY_VALUE="$(security find-generic-password -a "$USER" -s OPENAI_API_KEY -w 2>/dev/null)"
#   [ -n "$OPENAI_API_KEY_VALUE" ] && export OPENAI_API_KEY="$OPENAI_API_KEY_VALUE"


  # WARP_API_KEY_VALUE="$(security find-generic-password -a "$USER" -s WARP_API_KEY -w 2>/dev/null)"
  # [ -n "$WARP_API_KEY_VALUE" ] && export WARP_API_KEY="$WARP_API_KEY_VALUE"

fi

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Gastown multi-agent workspace manager (gt name is taken by Graphite)
alias gastown="/opt/homebrew/opt/gastown/bin/gastown"
alias md='glow'

# >>> open-knowledge cli >>>
# ! Contents within this block are managed by OpenKnowledge. Do not edit.
# ! Delete this whole block to opt out — OpenKnowledge will not re-add it.
[ -f "$HOME/.ok/env.sh" ] && . "$HOME/.ok/env.sh"
# <<< open-knowledge cli <<<

alias pi='npx @earendil-works/pi-coding-agent'
alias dotfils='dotfiles'
export PATH="$HOME/.local/bin:$PATH"

# --- Gas Town Integration (managed by gt) ---
[[ -f "/Users/elvis/.config/gastown/shell-hook.sh" ]] && source "/Users/elvis/.config/gastown/shell-hook.sh"
# --- End Gas Town ---
