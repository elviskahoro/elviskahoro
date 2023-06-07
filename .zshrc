 
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    eval "$(rbenv init - zsh)"
    eval $(thefuck --alias)
fi
. "$HOME/.cargo/env"
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(pyenv init --path)"
eval "$(starship init zsh)"

