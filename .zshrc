 
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
. "$HOME/.cargo/env"

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    eval "$(starship init zsh)"
    eval "$(rbenv init - zsh)"
fi

eval "$(starship init zsh)"
# eval "$(starship init zsh)"
# eval "$(pyenv init -)"
# eval "$(direnv hook zsh)"
