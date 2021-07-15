# run tmux at start
if [ -z "$TMUX" ]; then
	tmux attach -t default || tmux new -s default
fi

export PATH="/usr/local/opt/m4/bin:$PATH"
export PATH="/usr/local/opt/bzip2/bin:$PATH"
export PATH="/usr/local/opt/apr/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export MONO_GAC_PREFIX="/usr/local"

export PYENV_SHELL=bash
source '/usr/local/Cellar/pyenv/2.0.2/libexec/../completions/pyenv.bash'
command pyenv rehash 2>/dev/null
pyenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(pyenv "sh-$command" "$@")"
    ;;
  *)
    command pyenv "$command" "$@"
    ;;
  esac
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/elvis/google-cloud-sdk/path.bash.inc' ]; then . '/Users/elvis/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/elvis/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/elvis/google-cloud-sdk/completion.bash.inc'; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init -)"

# SOURCE

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

alias spull='git submodule foreach --recursive "git pull"'
alias smaster='git submodule foreach --recursive "git checkout master"'
alias sstash='git submodule foreach --recursive "git stash"'

alias strack='git stash --include-untracked'

alias tkill='tmux kill-session'

alias o='./output'
alias mb='ls -lah'
alias MB='ls -l --block-size=M'

# rc files
alias dfi='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias bashrc='vim ~/.bashrc'
alias inputrc='vim ~/.inputrc'
alias sshrc='vim ~/.ssh/config'
alias tmuxrc='vim ~/.tmux.conf'
alias vimrc='vim ~/.vimrc'

alias python=python3
alias jekyll='bundle exec jekyll serve'
alias ve='source ~/ve/bin/activate'
