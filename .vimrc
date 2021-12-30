colorscheme monokai
set autochdir
set autoindent
set autoread
set backspace=indent,eol,start
set clipboard^=unnamed,unnamedplus
set cmdheight=2
set colorcolumn=80
set complete-=i
set cursorline
set display+=lastline
set encoding=utf-8
set expandtab
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set hidden
set history=1000
set ignorecase
set lazyredraw
set nobackup
set nowritebackup
set nocompatible
set nowrap
set nrformats-=octal
set number
set ruler
set scrolloff=3
set shiftwidth=4
set sessionoptions-=options
set shortmess+=c
set showcmd
set showmatch
set smartindent
set smarttab
set softtabstop=4
set splitright
set splitbelow
set tabstop=4
set viewoptions-=options
set wildmenu
set wrapscan
set viewoptions-=options

filetype plugin on
syntax on

let mapleader = ";"

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>

"remap world
nnoremap j gj
nnoremap k gk
nnoremap gV `[v`]
nnoremap dil ^d$

" File Explorer usage
let g:netrw_banner = 0
let g:netrw_liststyle = 4
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 80

set incsearch
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

" vimplugged ------------------------------------------------------------------
if has('nvim')
    set signcolumn=number
    call plug#begin(stdpath('data') . '/plugged')
else
    set signcolumn=yes
    if &ttimeoutlen == -1
      set ttimeout
      set ttimeoutlen=100
    endif
    call plug#begin('~/.vim/plugged')
endif
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'chrisbra/Colorizer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'itchyny/lightline.vim'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'ap/vim-buftabline'
Plug 'tpope/vim-vinegar'
Plug 'tmux-plugins/vim-tmux'
Plug 'roxma/vim-tmux-clipboard'
Plug 'honza/vim-snippets' 
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
set updatetime=100 " signify - async time reset

call plug#end()
" vimplugged ------------------------------------------------------------------

" lightlinedoc-----------------------------------------------------------------
if !has('gui_running')
  set t_Co=256
endif
set laststatus=2
set noshowmode
let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'cocstatus': 'coc#status'
    \ },
    \ }
" lightlinedoc-----------------------------------------------------------------

" fzfdoc-----------------------------------------------------------------------
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

nnoremap <silent> <Leader>f :Files<CR>
nnoremap <silent> <Leader>F :Rg<CR>
" fzfdoc-----------------------------------------------------------------------

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


