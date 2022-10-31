 
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
. "$HOME/.cargo/env"

eval "$(rbenv init - zsh)"
# eval "$(starship init zsh)"
# eval "$(pyenv init -)"
# eval "$(direnv hook zsh)"
