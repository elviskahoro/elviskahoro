alias ve='source /Users/elvis/Library/Caches/pypoetry/virtualenvs/warpdotdev-dx-_OAhpmWh-py3.10/bin/activate'

alias cddocs='cd ~/Documents/'
alias cdconfig='cd ~/Documents/dx/.trunk/config'
alias cdworkspace='cd ~/Documents/workspace'
alias cdshowcase='cd ~/Documents/showcase'
alias cdobsidian='cd ~/Documents/obsidian'
alias cdgb='cd ~/Documents/dx/src/gitbook'
alias cdcv='cd ~/Documents/dx/src/channel-versions'
alias cdx='cd ~/Documents/dx'
alias cdgitbook='cd ~/Documents/dx/src/gitbook'
alias cdthemes='cd ~/Documents/dx/src/warp/themes'
alias cdwarp='cd ~/Documents/dx/src/Warp'
alias cdwi='cd ~/Documents/warp-internal'
alias cdworkflows='cd ~/Documents/dx/src/Warp/workflows'

alias ngroks='ngrok start warpdotdev'
alias g='git'
alias la='ls -a'
alias mb='ls -lah'
alias MB='ls -l --block-size=M'
alias o='./output'
alias t='tig'
alias tnew='tmux new -s'
alias tkill='tmux kill-session'
alias cp='cp -i'
alias d='cd'
alias less='less -R'
alias mkdir='mkdir -p'
alias mv='mv -i'
alias rmi='rm -iv'
alias ping='ping -c 10'
alias ps='ps auxf'
alias vi='mvim'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

alias rcbp='vim ~/.bash_profile'
alias rcb='vim ~/.bashrc'
alias rcbs='source ~/.bashrc'
alias rcg='vim ~/.gitconfig'
alias rcgm='vim ~/.config/git/.gitmessage'
alias rci='vim ~/.inputrc'
alias rcnvim='vim ~/.config/nvim/init.vim'
alias rcsh='vim ~/.ssh/config'
alias rcterm='vim ~/.config/alacritty/alacritty.yml'
alias rctig='vim ~/.tigrc'
alias rctmux='vim ~/.tmux.conf'
alias rcvim='vim ~/.vimrc'
alias rcp="vim ~/.profile"
alias rcz="vim ~/.zshenv"
alias rczp="vim ~/.zprofile"
alias rcz="vim ~/.zshrc"
alias rczlogin="vim ~/.zlogin"
alias rczlogout="vim ~/.zlogout"

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

alias ~='cd ~'                              # Go Home
alias ..='cd ../'                           # Go back 1 directory
alias ...='cd ../../'                       # Go back 2 directory
alias .2='cd ../../'                        # Go back 2 directory
alias .3='cd ../../../'                     # Go back 3 directory
alias .4='cd ../../../../'                  # Go back 4 directory
alias .5='cd ../../../../../'               # Go back 5 directory
alias .6='cd ../../../../../../'            # Go back 6 directory

