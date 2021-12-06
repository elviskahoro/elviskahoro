if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    set -o vi
    set show-mode-in-prompt on

    # possible modes for bind
    # vi
    # vi-move
    # vi-command
    # vi-insert

    set editing-mode vi
    set keymap vi-command
    if [ "$(uname)" == "Darwin" ]; then 
        bind '"p": "i $(echo $(pbpaste))\e"'
    else
        bind '"p": "i $(echo $(xclip -selection c -o))\e"'
    fi
#    bind 'TAB: menu-complete'
#    bind '"jk": vi-movement-mode'
#    bind '"\e[Z": menu-complete-backward'

#    '"\C-d": vi-eof-maybe'
#    '"\C-n": menu-complete'
#    '"\C-p": menu-complete-backward'

#    set keymap vi-insert
#    bind '"p": self-insert'
#    bind 'Control-l: clear-screen'


#    set vi-ins-mode-string "\1\e[6 q\2"
#    set vi-cmd-mode-string "\1\e[2 q\2"

#    bind '"\e": vi-movement-mode'
#    bind '"\C-d": delete-char'
#    bind '"\C-n": next-history'
#    bind '"\C-p": previous-history'
#    bind '"\e": "kj" '
#    
#    bind '"\C-d": delete-char # eof-maybe: ^D does nothing if there is text on the line'
#    bind '"\C-n": menu-complete'
#    bind '"\C-p": menu-complete-backward'
#    bind '"\C-y": previous-history # history'
#    bind '"\e\C-y": previous-history'
#    bind vi-insert '"\C-x\C-e": edit-and-execute-command'
#    bind vi-insert '"\C-x\C-e": edit-and-execute-command'
#    bind '"v": ""'
fi
