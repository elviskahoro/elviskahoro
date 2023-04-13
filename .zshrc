 
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
. "$HOME/.cargo/env"

if [[ $TERM_PROGRAM == "WarpTerminal" ]]; then
    eval "$(starship init zsh)"
fi
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    eval "$(rbenv init - zsh)"
    eval $(thefuck --alias)
fi
eval "$(starship init zsh)"
