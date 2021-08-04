colorscheme monokai

set autochdir
set autoindent
set autoread
set backspace=indent,eol,start
set clipboard^=unnamed,unnamedplus
set complete-=i
set cursorline
set display+=lastline
set encoding=utf-8
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set history=1000
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set nocompatible
set noswapfile
set nowrap
set nrformats-=octal
set number
set ruler
set scrolloff=3 " keep three lines between the cursor and the edge of the screen
set sessionoptions-=options
set showcmd
set showmatch
set smarttab
set splitright
set splitbelow
set viewoptions-=options
set updatetime=100 " signify - async time reset
set wildmenu
set wrapscan  " begin search from top of file when nothing is found anymore
set viewoptions-=options

"remap world
nnoremap j gj
nnoremap k gk
nnoremap gV `[v`]

" File Explorer usage
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 2
let g:netrw_altv = 1
let g:netrw_winsize = 80

if maparg('<C-L>', 'n') ==# '' " incsearch  Use <C-L> to clear the highlighting of :set hlsearch.
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

" has
if has('autocmd')
  filetype plugin indent on
endif
if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

" if
if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
if &t_Co == 8 && $TERM !~# '^Eterm' " Allow color schemes to do bright colors without forcing bold.
  set t_Co=16
endif
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j " Delete comment character when joining commented lines
endif
if empty(mapcheck('<C-U>', 'i'))
  inoremap <C-U> <C-G>u<C-U>
endif
if empty(mapcheck('<C-W>', 'i'))
  inoremap <C-W> <C-G>u<C-W>
endif
if !empty(&viminfo)
  set viminfo^=!
endif

" Neovim --------------------------------------------------------------------------------------------------------------------------------------
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Vim Plugged ---------------------------------------------------------------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
Plug 'lervag/vimtex'
Plug 'roxma/vim-tmux-clipboard'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tmux-plugins/vim-tmux'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'itchyny/lightline.vim'
Plug 'mileszs/ack.vim'
Plug 'junegunn/goyo.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
call plug#end()

let python_highlight_all=1
au BufNewFile,BufRead *.py;
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set list listchars=tab:▷⋅,trail:⋅,nbsp:⋅ |

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
