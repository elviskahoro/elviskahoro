if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set keymap vi-command
    bind -r '"v": ""'
    if [ "$(uname)" == "Darwin" ]; then "p": self-insert
        bind '"p": "i $(echo $(pbpaste))\e"'
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # linux
        bind '"p": "i $(echo $(xclip -selection c -o))\e"'
    fi
    set editing-mode vi
    set keymap vi-insertef
    bind '"jk": vi-movement-mode'

    set keymap vi-insert
    bind 'TAB: menu-complete'
    bind '"\e[Z": menu-complete-backward'
fi
