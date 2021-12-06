if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi

    # possible modes for bind
    # vi
    # vi-move
    # vi-command
    # vi-insert

    bind -m vi-command '"v": ""'
    bind -m vi-command '"\C-w": "i exit\r"'
    bind -m vi-insert '"\C-l": clear-screen'
    bind -m vi-insert '"\C-d": delete-char'
    bind -m vi-insert '"\C-n": next-history'
    bind -m vi-insert '"\C-p": previous-history'
    bind -m vi-insert '"TAB": menu-complete'
    bind -m vi-insert '"\e[Z": menu-complete-backward'
#    if [ "$(uname)" == "Darwin" ]; then 
#        bind -m vi-command '"\C-v": "i $(echo $(pbpaste))\e"'        
#    else
#        bind -m vi-command '\C-v": "i $(echo $(xclip -selection c -o))\e"'
#    fi
fi
