if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi

    set keymap vi-command
#    if [ "$(uname)" == "Darwin" ]; then 
#        bind '"p": "i $(echo $(pbpaste))\e"'
#    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
#        # linux
#        bind '"p":i (echo $(xclip -selection c -o))\e'
#    fi
    bind -r 'TAB: menu-complete'
    bind -r '"jk": vi-movement-mode'
    bind -r '"\e[Z": menu-complete-backward'
    bind -r '"v": ""'

    set keymap vi-insert
    # bind '"p": self-insert'
    bind 'Control-l: clear-screen'
fi
