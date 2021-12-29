alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotr='cp ~/.zlogin ~/zlogin_mac.sh'

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi
    CASE_SENSITIVE="false"
fi

export PATH="$HOME/.poetry/bin:$PATH"
