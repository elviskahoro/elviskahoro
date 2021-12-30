if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi
    CASE_SENSITIVE="false"
    [ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh

#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####

fi

alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dotr='cp ~/.zlogin ~/zlogin_mac.sh'

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi


export PATH="$HOME/.poetry/bin:$PATH"
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then

    #### FIG ENV VARIABLES ####
    # Please make sure this block is at the end of this file.
    [ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
    #### END FIG ENV VARIABLES ####

fi
