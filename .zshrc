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

export GASTOWN_DISABLED=1

alias gastown="/opt/homebrew/opt/gastown/bin/gastown"
alias gt='graphite'
alias md='glow'

# gbds: sync .beads/ changes from the current branch into main, without
# checking main out or touching the current working tree.
gbds() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel) || return 1

  if [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = "main" ]; then
    echo "gbds: already on main" >&2
    return 1
  fi

  if [ -z "$(git status --porcelain -- .beads)" ]; then
    echo "gbds: no changes under .beads" >&2
    return 1
  fi

  local wt_dir
  wt_dir=$(mktemp -d)
  git worktree add -q "$wt_dir" main || return 1

  rsync -a --delete "$repo_root/.beads/" "$wt_dir/.beads/"

  (
    cd "$wt_dir" || exit 1
    git add .beads
    if git diff --cached --quiet; then
      echo "gbds: nothing to commit on main" >&2
    else
      git commit -q -m "chore: sync .beads"
      echo "gbds: committed to main ($(git rev-parse --short HEAD))"
    fi
  )

  git worktree remove "$wt_dir" --force
}

# >>> open-knowledge cli >>>
# ! Contents within this block are managed by OpenKnowledge. Do not edit.
# ! Delete this whole block to opt out — OpenKnowledge will not re-add it.
[ -f "$HOME/.ok/env.sh" ] && . "$HOME/.ok/env.sh"
# <<< open-knowledge cli <<<

alias pi='npx @earendil-works/pi-coding-agent'
alias dotfils='dotfiles'
export PATH="$HOME/.local/bin:$PATH"

# > [|o=o|] > paper shell init script > [|o=o|] >
if [ -x "$HOME/.local/bin/paperctl" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi
# < [|o=o|] < paper shell init < [|o=o|] <


# Added by Antigravity CLI installer
export PATH="/Users/elvis/.local/bin:$PATH"

PATH="/Users/elvis/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/elvis/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/elvis/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/elvis/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/elvis/perl5"; export PERL_MM_OPT;
