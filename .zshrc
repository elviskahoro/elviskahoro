alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotr='cp ~/.zlogin ~/zlogin_mac.sh'

alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi
    CASE_SENSITIVE="false"
fi
