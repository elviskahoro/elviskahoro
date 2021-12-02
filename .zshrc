alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotr='cp ~/.zlogin ~/zlogin_mac.sh'

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
