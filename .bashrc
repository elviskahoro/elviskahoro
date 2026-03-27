function cdl {
  cd "$(walk "$@")"
}
function cdf() {
  local path="${1/#\~/$HOME}"  # Expand ~ to $HOME
  cd "${path%/*}"
}
#alias run='modal run'

alias ai='cd /Users/elvis/Documents/elviskahoro/ai'

alias batp='bat --paging=never'
alias bl='black'
alias bbl='black'
alias vbl='black'

alias brwe='brew'
alias brw='brew'
alias cb='cargo build'

#alias code='positron'
alias c='cdl'
alias cod='code'
alias cp='cp -i'
alias cr='coderabbit'

alias dopller='doppler'
alias down='cd ~/Downloads/'
alias docs='cd ~/Documents/'
alias dui='duckdb --ui'

alias ekk='cd /Users/elvis/Documents/elviskahoro'
alias exa='eza'

alias fmt='trunk fmt'
alias nfm='fnm'

alias grow='cd /Users/elvis/Documents/elviskahoro/growth-machine'
alias growth='cd /Users/elvis/Documents/elviskahoro/growth-machine'

alias home='cd /Users/elvis/Documents/elviskahoro/obsidian'

alias jt='jupyter-lab'
alias less='less -R'
alias ls='eza -a --long'
alias le='ls'

alias lsc='eza | wc -l'
alias lsd='eza -a --long -D'
alias lsl='lsd'
alias lks='lsd'
alias lsf='eza --oneline'

alias mkdir='mkdir -p'
alias mdir='mkdir -p'
alias mkldir='mkdir -p'
alias mo='marimo'
alias mv='mv -i'

alias ngroks='ngrok start warpdotdev'

alias pyen='pyenv'
alias peynv='pyenv'
alias pyuenv='pyenv'

alias o='open'
alias opne='open'
alias openm='open'
alias ope='open'

alias play='cd ~/Documents/elviskahoro/playground'
alias cplay='play'
alias cplayh='play'
alias ping='ping -c 10'
alias pi='uv pip'
alias pipu='uv pip'
alias pipuv='uv pip'
alias piv='uv pip'
alias pipv='uv pip'
alias pre='pre-commit run --all-files'
alias ps='ps auxf'
alias pygithub='cd /Users/elvis/Library/Caches/pypoetry/virtualenvs/warpdotdev-dx-_OAhpmWh-py3.10/lib/python3.10/site-packages/github'
alias py='python'
alias powd='pwd'

alias rgf='rg -l'
alias rmi='rm -iv'
alias refelx='reflex'
alias rr='reflex run'
alias rrld='reflex run --loglevel=debug'
alias rvx='vim ~/.zshrc'
alias rcv='vim ~/.bashrc'

alias sl='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias slide='slides'
alias slid='slides'
alias sli='slides'

alias test='pytest -n auto -v'
alias tc='trunk check'
alias tnew='tmux new -s'
alias tkill='tmux kill-session'

alias uvr='uv pip install -r requirements.txt'

alias ve='source .venv/bin/activate'
alias vve='source .venv/bin/activate'
alias verx='source /Users/elvis/Library/Caches/pypoetry/virtualenvs/reflex-NF09o5gF-py3.11/bin/activate'
alias vce='source .venv/bin/activate'
alias vs='positron'

alias warp='oz'
alias awrp='warp'
alias whitelist='code /Users/elvis/Documents/reflex-dev/reflex-web/pcweb/whitelist.py'
alias white='code /Users/elvis/Documents/reflex-dev/reflex-web/pcweb/whitelist.py'
alias ws='positron'
alias writer='cd /Users/elvis/Documents/elviskahoro/writer'

alias yran='yarn'
alias yuarn='yarn'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='eza --tree --git-ignore'
alias treed='eza --tree --git-ignore --only-dirs'
alias mountedinfo='df -hT'

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
alias ....='cd ../../../'                       # Go back 2 directory
alias .2='cd ../../'                        # Go back 2 directory
alias .3='cd ../../../'                     # Go back 3 directory
alias .4='cd ../../../../'                  # Go back 4 directory
alias .5='cd ../../../../../'               # Go back 5 directory
alias .6='cd ../../../../../../'            # Go back 6 directory

alias rcbp='vim ~/.bash_profile'
alias rcb='vim ~/.bashrc'
alias rb='vim ~/.bashrc'
alias rcgb='vim ~/.bashrc'
alias rbc='vim ~/.bashrc'
alias rcbs='source ~/.bashrc'
alias rcg='vim ~/.gitconfig'
alias rcgf='vim ~/.gitconfig'
alias rcgm='vim ~/.config/git/.gitmessage'
alias rci='vim ~/.inputrc'
alias rcnvim='vim ~/.config/nvim/init.vim'
alias rcsh='vim ~/.ssh/config'
alias rcterm='vim ~/.config/alacritty/alacritty.yml'
alias rctig='vim ~/.tigrc'
alias rctmux='vim ~/.tmux.conf'
alias rcvim='vim ~/.vimrc'
alias rcp="vim ~/.profile"
alias rczp="vim ~/.zprofile"
alias rcze="vim ~/.zshenv"
alias rcz="vim ~/.zshrc"
alias zshrc="vim ~/.zshrc"
alias rczlogin="vim ~/.zlogin"
alias rczlogout="vim ~/.zlogout"
alias rcl="vim ~/.claude.json"


alias cdcd='cd ~/Desktop'
alias cdd='cd ~/Desktop'
alias cdc='cd ~/Documents/chalk'
alias cdt='cd ~/Desktop/test/temp'
alias cddt='cd ~/Desktop/test/temp'
alias cdx='cd ~/Documents/chalk-ai'
alias dcx='cd ~/Documents/reflex-dev/devx'
alias ccdx='cd ~/Documents/reflex-dev/devx'
alias cdv='cd ~/Documents/reflex-dev/devx'
alias vdx='cd ~/Documents/reflex-dev/devx'
alias dx='cd ~/Documents/reflex-dev/devx'
alias cx='cd ~/Documents/reflex-dev/devx'
alias fcdx='cd ~/Documents/reflex-dev/devx'
alias cdr='cd ~/Documents/reflex-dev'
alias cddocs='cd ~/Documents/'
alias cdobsidian='cd ~/Documents/obsidian'
alias cdshowcase='cd ~/Documents/showcase'
alias cdtrunk='cd ~/Documents/devx/.trunk/config'
alias cdworkspace='cd ~/Documents/workspace'
alias cdwork='cd ~/Documents/workspace'
alias desk='cd ~/Desktop'
alias deks='cd ~/Desktop'
alias dsk='cd ~/Desktop'
alias elvis='cd ~/Documents/elviskahoro'

alias g='git'
alias ag='g'
alias gb='g'
alias G='g'
alias h='g'
alias q='g'
alias t='g'
alias gg='g'
alias ga='g'
alias gi='g'
alias cg='g'
alias eg='g'
alias jg='g'
alias lg='g'
alias qg='g'
alias tg='g'
alias wg='g'
alias yg='g'
alias gig='g'
alias qga='g'
alias yyg='g'
alias ggit='g'
alias gitg='g'

alias gaa='g aa'
alias au='g au'
alias gua=' gau'
alias gau='g au'
alias gbc='g bc'
alias gbd='g bd'
alias qgbd='g bd'
alias brn='g brn'
alias bu='g bu'
alias bbu='g bu'
alias gbu='g bu'
alias bucc='g bucc'
alias buc='g bucc'
alias bnucc='g bucc'
alias gbcc='g bucc'
alias bcc='g bucc'
alias ucc='g bucc'
alias gbrd='g gbrd'
alias ca='g ca'
alias gca= 'g ca'
alias cca='g cca'
alias gcca='g cca'
alias gbca='g bca'
alias cc='g cc'
alias gch='g ch'
alias co='g co'
alias gco='g co'
alias ct='g ct'
alias gct='g ct'
alias gtc='gt ct'
alias gd='g d'
alias d='g d'
alias dc='g dc'
alias dl='g dl'
alias gdl='g dl'
alias gl='g l'
alias gls='g ls-files'
alias pull='g pull'
alias psuh='g push'
alias push='g push'
alias gpush='g push'
alias poush='g push'
alias puush='g push'
alias pusrh='g push'
alias ush='g push'
alias reo='g reo'
alias greo='g reo'
alias grs='g rs'
alias gs='g s'
alias gst=' g st'
alias gsta='g sta'
alias sta='g sta'
alias stp='g stp'
alias gspt='g stp'
alias stash='g stash'
alias gstd=' g std'
alias gstp='g stp'
alias tp='g stp'
alias ggco='g gso'
alias gto='g to'
alias got='g to'
alias gtgo='g to'
alias gtopen='g to'
alias gtop='g top'
alias guso='g uso'
alias uso='g uso'
alias usr='g usr'
alias gusr='g usr'
alias suo='g uso'
alias pul='g pull'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/elvis/.lmstudio/bin"
# End of LM Studio CLI section
