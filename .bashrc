# move to bashp
# $(brew --prefix)/opt/fzf/install

set -o vi
bind TAB:menu-complete

# export TERM=xterm-256color # vim/lightline

alias vi='nvim'
alias g='git'
alias o='./output'
alias t='tig'
alias mb='ls -lah'
alias MB='ls -l --block-size=M'
alias pip='python3 -m pip'
alias pipr='python3 -m pip install -r requirements.txt'
alias prun='pelican --autoreload --listen'
alias tnew='tmux new -s'
alias tkill='tmux kill-session'
alias ve='source ~/ve/bin/activate'

alias bashp='vim ~/.bash_profile'
alias bashrc='vim ~/.bashrc'
alias gitrc='vim ~/.gitconfig'
alias inputrc='vim ~/.inputrc'
alias nvimrc='vim ~/.config/nvim/init.vim'
alias sshrc='vim ~/.ssh/config'
alias tigrc='vim ~/.tigrc'
alias tmuxrc='vim ~/.tmux.conf'
alias vimrc='vim ~/.vimrc'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# if [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
# fi
# 

shopt -s checkwinsize
shopt -s histappend
PROMPT_COMMAND='history -a'

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias apt-get='sudo apt-get'

alias ~='cd ~'                              # Go Home
alias ..='cd ../'                           # Go back 1 directory
alias ...='cd ../../'                       # Go back 2 directory
alias .2='cd ../../'                        # Go back 2 directory
alias .3='cd ../../../'                     # Go back 3 directory
alias .4='cd ../../../../'                  # Go back 4 directory
alias .5='cd ../../../../../'               # Go back 5 directory
alias .6='cd ../../../../../../'            # Go back 6 directory

# Alias's for multiple directory listing commands
alias la='ls -aFhl --color=always' # add colors and file type extensions
alias ls='ls -Fhl --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lb='ls -lSrh' # sort by size
alias lt='ls -ltrh' # sort by date
alias ltc='ls -lcrh' # sort by change time
alias lta='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format
alias labc='ls -lap' #alphabetical sort
alias lfil="ls -l | egrep -v '^d'" # files only
alias lfol="ls -l | egrep '^d'" # directories only

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search running processes
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"
# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"
# Show open ports
alias openports='netstat -nape --inet'
# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

function gdiff()
{
	if [ $# -eq 0 ]; then
		git diff HEAD~1
	else
		git diff HEAD~$1
	fi
}

function gshow()
{
	if [ $# -eq 0 ]; then
		git show
	else
		git show HEAD~$1
	fi
}

function spush()
{
	if [ $# -eq 0 ]; then
		git submodule foreach --recursive "git add ."
		git submodule foreach --recursive "git commit -m c"
		git push --recurse-submodules=on-demand
	else
		git submodule foreach --recursive "git add ."
		git submodule foreach --recursive "git commit -m $1"
		git push --recurse-submodules=on-demand
	fi
}

function ide()
{
    tmux split-window -v -p 30
    tmux split-window -h -p 66
    tmux split-window -h -p 50
}

