 
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    eval "$(rbenv init - zsh)"
    eval $(thefuck --alias)
fi
eval "$(starship init zsh)"
eval "$(pyenv init --path)"
. "$HOME/.cargo/env"
