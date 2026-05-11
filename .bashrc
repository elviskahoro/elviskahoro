# Environment & Setup
[ -f "$HOME/.env.local" ] && source "$HOME/.env.local"

# Load API keys from macOS Keychain for new shells.
# Add once with:
# security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w "sk-..."
# security add-generic-password -U -a "$USER" -s ANTHROPIC_API_KEY -w "sk-ant-..."
# security add-generic-password -U -a "$USER" -s WARP_API_KEY -w "oz_default_..."
if command -v security >/dev/null 2>&1; then
  OPENAI_API_KEY_VALUE="$(security find-generic-password -a "$USER" -s OPENAI_API_KEY -w 2>/dev/null)"
  [ -n "$OPENAI_API_KEY_VALUE" ] && export OPENAI_API_KEY="$OPENAI_API_KEY_VALUE"

  ANTHROPIC_API_KEY_VALUE="$(security find-generic-password -a "$USER" -s ANTHROPIC_API_KEY -w 2>/dev/null)"
  [ -n "$ANTHROPIC_API_KEY_VALUE" ] && export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_VALUE"

  # WARP_API_KEY_VALUE="$(security find-generic-password -a "$USER" -s WARP_API_KEY -w 2>/dev/null)"
  # [ -n "$WARP_API_KEY_VALUE" ] && export WARP_API_KEY="$WARP_API_KEY_VALUE"
fi

# Functions
function cdf() {
  local path="${1/#\~/$HOME}"  # Expand ~ to $HOME
  cd "${path%/*}"
}

function cdl {
  cd "$(walk "$@")"
}

cdt() {
  local path
  path=$(/usr/bin/git worktree list --porcelain | /usr/bin/awk -v name="$1" '
    $1 == "worktree" {
      current = substr($0, 10)
      if (index(current, name)) {
        print current
        exit
      }
    }
  ')
  if [ -z "$path" ]; then
    echo "Worktree '$1' not found"
    return 1
  fi
  cd "$path"
}

git_bcw() {
  local name="$1"
  git worktree add -b "$name" "../worktrees/$name" && cd "../worktrees/$name"
}

# Navigation - Directory shortcuts
alias ~='cd ~'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

alias ai='cd /Users/elvis/Documents/ai'
alias apollo='cd /Users/elvis/Documents/elviskahoro/ai/gtm/apollo'
alias attio='cd /Users/elvis/Documents/elviskahoro/ai/gtm/attio'

alias c='cdl'
alias ccdx='cd ~/Documents/reflex-dev/devx'
alias cdc='cd ~/Documents/chalk'
alias cdcd='cd ~/Desktop'
alias cdd='cd ~/Desktop'
alias cddocs='cd ~/Documents/'
alias cddt='cd ~/Desktop/test/temp'
alias cdobsidian='cd ~/Documents/obsidian'
alias cdr='cd ~/Documents/reflex-dev'
alias cdshowcase='cd ~/Documents/showcase'
alias cdtrunk='cd ~/Documents/devx/.trunk/config'
alias cdv='cd ~/Documents/reflex-dev/devx'
alias cdwork='cd ~/Documents/workspace'
alias cdworkspace='cd ~/Documents/workspace'
alias cdx='cd ~/Documents/chalk-ai'
alias cplay='play'
alias cplayh='play'
alias cx='cd ~/Documents/reflex-dev/devx'

alias dcx='cd ~/Documents/reflex-dev/devx'
alias deks='cd ~/Desktop'
alias demo='cd /Users/elvis/Documents/elviskahoro/demo'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents/'
alias dofiles='dotfiles'
alias dotfiels='dotfiles'
alias dotfiles='cd /Users/elvis/Documents/elviskahoro/dotfiles'
alias down='cd ~/Downloads/'
alias dsk='cd ~/Desktop'
alias dx='cd ~/Documents/reflex-dev/devx'

alias ekk='cd /Users/elvis/Documents/elviskahoro'
alias elvis='cd ~/Documents/elviskahoro'

alias fcdx='cd ~/Documents/reflex-dev/devx'

alias grow='cd /Users/elvis/Documents/elviskahoro/growth-machine'
alias growth='cd /Users/elvis/Documents/elviskahoro/growth-machine'

alias home='cd /Users/elvis/Documents/elviskahoro/obsidian'

alias os='cd /Users/elvis/Documents/dlt-hub/gtm-os'

alias play='cd ~/Documents/elviskahoro/playground'

alias skills='cd /Users/elvis/Documents/elviskahoro/ai/.agents/skills'
alias sills='skills'
alias skils='skills'

alias vdx='cd ~/Documents/reflex-dev/devx'
alias video='cd /Users/elvis/Downloads/videos'

alias writer='cd /Users/elvis/Documents/elviskahoro/writer'

alias zotero='cd ~/Documents/elviskahoro/zotero'

# Tools - Shortcuts & overrides
alias ab='uv run attio-backfill'
alias awrp='warp'

alias batp='bat --paging=never'
alias bbl='black'
alias bl='black'
alias brw='brew'
alias brwe='brew'

alias cb='cargo build'
alias cla='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias clx='codex --yolo'
alias cod='code'
alias cr='coderabbit'
alias cs='cursor'
alias cursor='cursor'
alias cursors='cursor'

alias dopller='doppler'
alias dui='duckdb --ui'

alias exa='eza'

alias fmt='trunk fmt'

alias jt='jupyter-lab'

alias less='less -R'

alias marimio='marimo'
alias mo='uv run marimo edit notebook.py --watch --no-token'

alias nfm='fnm'
alias ngroks='ngrok start warpdotdev'

alias o='open'
alias ope='open'
alias openm='open'
alias opne='open'

alias ping='ping -c 10'
alias pre='pre-commit run --all-files'
alias py='python'
alias pygithub='cd ~/Library/Caches/pypoetry/virtualenvs/warpdotdev-dx-_OAhpmWh-py3.10/lib/python3.10/site-packages/github'

alias refelx='reflex'
alias rr='reflex run'
alias rrld='reflex run --loglevel=debug'

alias sclaude='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias scodex='codex --yolo'
alias senv='source .env.local'
alias slc='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias sli='slides'
alias slid='slides'
alias slide='slides'
alias slx='codex --yolo'

alias tc='trunk check'
alias test='pytest -n auto -v'
alias tkill='tmux kill-session'
alias tnew='tmux new -s'
alias trkn='trunk'
alias trukn='trunk'

alias urp='uv run python'
alias uvr='uv pip install -r requirements.txt'

alias vbl='black'
alias vs='positron'

alias warp='oz'
alias ws='positron'

# File operations
alias cp='cp -i'

alias kmdir='mkdir -p'
alias mdkdir='mkdir -p'
alias mkdr='mkdir -p'

alias mdir='mkdir -p'
alias mkdir='mkdir -p'
alias mkldir='mkdir -p'
alias mv='mv -i'

alias rmi='rm -iv'

alias verm='find . -maxdepth 1 -not -name ".venv" -not -name "." -not -name ".." -not -name ".git" -exec rm -rf {} +'

# File listing & tree
alias le='ls'
alias lks='lsd'
alias ls='eza --absolute --oneline --git --group-directories-first --all --no-permissions --no-user'
alias lsc='eza | wc -l'
alias lsd='eza --absolute --oneline --git --all --no-permissions --no-user -D'
alias lsf='eza --absolute --oneline --git --all --no-permissions --no-user -f'
alias lsl='lsd'
alias lst='eza --absolute --long --git --group-directories-first --all --modified --time-style=relative --no-permissions --no-user'

alias rgf='rg -l'

alias sl='ls'

alias tree='eza --tree --git-ignore'
alias treed='eza --tree --git-ignore --only-dirs'

# System utilities
alias diskspace="du -S | sort -n -r |more"

alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'

alias mountedinfo='df -hT'

alias powd='pwd'
alias ps='ps auxf'

# Permissions
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

alias mx='chmod a+x'

# Python & data tools
alias datah='vd'
alias datal='tw'
alias dcsv='xan'
alias dparq='pqrs'

alias peynv='pyenv'
alias pi='uv pip'
alias pin='pip install --upgrade pip'
alias pipu='uv pip'
alias pipuv='uv pip'
alias pipv='uv pip'
alias piv='uv pip'
alias pyen='pyenv'
alias pyuenv='pyenv'

alias vce='source .venv/bin/activate'
alias ve='source .venv/bin/activate'
alias vve='source .venv/bin/activate'

# Config editors (rc aliases)
alias rb='vim ~/.bashrc'
alias rbc='vim ~/.bashrc'
alias rcb='vim ~/.bashrc'
alias rcbp='vim ~/.bash_profile'
alias rcbs='source ~/.bashrc'
alias rcfg='rcg'
alias rcg='vim ~/.gitconfig'
alias rcgb='vim ~/.bashrc'
alias rcgf='vim ~/.gitconfig'
alias rcgm='vim ~/.config/git/.gitmessage'
alias rci='vim ~/.inputrc'
alias rcl="vim ~/.claude.json"
alias rcnvim='vim ~/.config/nvim/init.vim'
alias rcp="vim ~/.profile"
alias rcsh='vim ~/.ssh/config'
alias rcterm='vim ~/.config/alacritty/alacritty.yml'
alias rctig='vim ~/.tigrc'
alias rctmux='vim ~/.tmux.conf'
alias rcv='vim ~/.bashrc'
alias rcvim='vim ~/.vimrc'
alias rcz="vim ~/.zshrc"
alias rczlogin="vim ~/.zlogin"
alias rczlogout="vim ~/.zlogout"
alias rczp="vim ~/.zprofile"
alias rcze="vim ~/.zshenv"
alias rvx='vim ~/.zshrc'

alias zshrc="vim ~/.zshrc"

# Git
alias ag='g'
alias au='g au'

alias bbc='g bucc'
alias bbu='g bu'
alias bcc='g bucc'
alias bnucc='g bucc'
alias brn='g brn'
alias bu='g bu'
alias buc='g bucc'
alias bucc='g bucc'

alias ca='g ca'
alias caix='g caix'
alias cc='g cc'
alias cca='g cca'
alias cg='g'
alias co='g co'
alias ct='g ct'

alias d='g d'
alias dc='g dc'
alias dl='g dl'

alias eg='g'

alias g='git'
alias G='g'
alias ga='g'
alias gaa='g aa'
alias gau='g au'
alias gb='g'
alias gbc='g bc'
alias gbca='g bca'
alias gbcc='g bucc'
alias gbd='g bd'
alias gbrd='g gbrd'
alias gbu='g bu'
alias gca='g ca'
alias gcca='g cca'
alias gcfa='g cfa'
alias gch='g ch'
alias gco='g co'
alias gct='g ct'
alias gd='g d'
alias gdl='g dl'
alias gg='g'
alias ggco='g gso'
alias ggit='g'
alias gi='g'
alias gig='g'
alias gitg='g'
alias gl='g l'
alias gls='g ls-files'
alias got='g to'
alias gpush='g push'
alias greo='g reo'
alias grs='g rs'
alias gs='g s'
alias gspt='g stp'
alias gst='g st'
alias gsta='g sta'
alias gstd='g std'
alias gstp='g stp'
alias gtc='gt ct'
alias gtgo='g to'
alias gto='g to'
alias gtop='g top'
alias gtopen='g to'
alias gua='gau'
alias guso='g uso'
alias gusr='g usr'

alias h='g'

alias jg='g'

alias lg='g'

alias poush='g push'
alias psuh='g push'
alias pul='g pull'
alias pull='g pull'
alias push='g push'
alias pusrh='g push'
alias puush='g push'

alias q='g'
alias qg='g'
alias qga='g'
alias qgbd='g bd'

alias reo='g reo'

alias sta='g sta'
alias stash='g stash'
alias stp='g stp'
alias suo='g uso'

alias t='g'
alias tg='g'
alias tp='g stp'

alias ucc='g bucc'
alias ush='g push'
alias uso='g uso'
alias usr='g usr'

alias wg='g'

alias yg='g'
alias yyg='g'
