if [ -r ~/.bashrc ]; then
   source ~/.bashrc
fi

# set rtp+=/usr/local/opt/fzf
unalias ls
alias python=python3
alias dot='/usr/local/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias pro='/usr/local/bin/git --git-dir=$HOME/.profiles/ --work-tree=$HOME'
alias pror='cp ~/.bash_profile ~/bash_profile_mac'

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/opt/m4/bin:$PATH"
export PATH="/usr/local/opt/bzip2/bin:$PATH"
export PATH="/usr/local/opt/apr/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export MONO_GAC_PREFIX="/usr/local"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PYENV_SHELL=bash
source '/usr/local/Cellar/pyenv/2.0.2/libexec/../completions/pyenv.bash'
command pyenv rehash 2>/dev/null

if [ -f '/Users/elvis/google-cloud-sdk/path.bash.inc' ]; then . '/Users/elvis/google-cloud-sdk/path.bash.inc'; fi
if [ -f '/Users/elvis/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/elvis/google-cloud-sdk/completion.bash.inc'; fi

eval "$(rbenv init -)"

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

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
if [ -f /usr/local/share/liquidprompt ]; then
    . /usr/local/share/liquidprompt
fi

