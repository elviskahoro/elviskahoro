alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotr='cp ~/.zlogin ~/zlogin_mac.sh'

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

eval "$(starship init zsh)"

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    export PATH="$HOME/.poetry/bin:$PATH"
fi
