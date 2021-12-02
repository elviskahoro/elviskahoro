alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias pro='/usr/local/bin/git --git-dir=$HOME/.profiles/ --work-tree=$HOME'
alias pror='cp ~/.zlogin ~/zlogin_mac.sh'

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
