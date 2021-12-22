alias bkb='honkit build'
alias bkr='honkit serve'
alias bks='honkit serve'
alias prc='gh pr create --web'
alias c='cd'
alias g='git'
alias la='ls -a -1'
alias mb='ls -lah'
alias MB='ls -l --block-size=M'
alias o='./output'
alias pip='python3 -m pip'
alias pipr='python3 -m pip install -r requirements.txt'
alias pgcp='gcloud builds submit'
alias profile='vim .profile'
alias prun='pelican --autoreload --listen'
alias python=python3
alias t='tig'
alias tnew='tmux new -s'
alias tkill='tmux kill-session'
alias ve='source ~/ve/bin/activate'
alias vi='nvim'

alias bashp='vim ~/.bash_profile'
alias bashrc='vim ~/.bashrc'
alias gitrc='vim ~/.gitconfig'
alias inputrc='vim ~/.inputrc'
alias nvimrc='vim ~/.config/nvim/init.vim'
alias sshrc='vim ~/.ssh/config'
alias termrc='vim ~/.config/alacritty/alacritty.yml'
alias tigrc='vim ~/.tigrc'
alias tmuxrc='vim ~/.tmux.conf'
alias vimrc='vim ~/.vimrc'
alias warpcd='cd ~/.warp/'
alias zshrc="vim ~/.zshrc"

alias cp='cp -i'
alias mv='mv -i'
alias rmi='rm -iv'
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

function squash()
{
	if [ $# -eq 0 ]; then
		echo "must be more than one"
	else
        if [ $1 -eq 1 ]; then
            echo "must be more than 1"
        else
		    git rebase -i HEAD~$1
        fi
	fi
}

function diff()
{
	if [ $# -eq 0 ]; then
		git diff HEAD~1
	else
		git diff HEAD~$1
	fi
}

function show()
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

function cvupdate()
{
    git rebase origin/main stable_changelog_generator
    git rebase origin/main webhook-gcp
    git rebase origin/main webhook-local
}
. "$HOME/.cargo/env"
