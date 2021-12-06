if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi

    set keymap vi-insert
    bind '"p": self-insert'
    bind 'Control-l: clear-screen'

    set keymap vi-command
    if [ "$(uname)" == "Darwin" ]; then 
        bind '"p": "i $(echo $(pbpaste))\e"'
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # linux
        bind '"p": (echo $(xclip -selection c -o))\e'
    fi
    bind 'TAB: menu-complete'
    bind '"jk": vi-movement-mode'
    bind '"\e[Z": menu-complete-backward'
    bind -r '"v": ""'

fi
