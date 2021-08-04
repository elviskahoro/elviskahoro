if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

alias ~='cd ~'                              # ~:            Go Home
alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .2='cd ../../'                        # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels

alias spull='git submodule foreach --recursive "git pull"'
alias smaster='git submodule foreach --recursive "git checkout master"'
alias sstash='git submodule foreach --recursive "git stash"'

alias strack='git stash --include-untracked'

alias tkill='tmux kill-session'

alias o='./output'
alias mb='ls -lah'
alias MB='ls -l --block-size=M'

# rc files
alias bashp='vim ~/.bash_profile'
alias bashrc='vim ~/.bashrc'
alias inputrc='vim ~/.inputrc'
alias sshrc='vim ~/.ssh/config'
alias tmuxrc='vim ~/.tmux.conf'
alias vimrc='vim ~/.vimrc'

alias ve='source ~/ve/bin/activate'

function c()
{
		gcc -o output $1
}

function gac()
{
	git commit --amend --no-edit
}

function gclean()
{
        if [ $# -eq 0 ]; then
                git reset HEAD~1
        else
		git reset HEAD~$1
        fi
}

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

function gpush()
{
	if [ $# -eq 0 ]; then
		git add .
		git commit -m c
		git push
	else
		git add .
		git commit -m $1
		git push
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

