syntax enable
colorscheme monokai
set autochdir
set clipboard^=unnamed,unnamedplus
set cursorline
set encoding=utf-8
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set ignorecase
set lazyredraw
set nocompatible
set noswapfile
set nowrap
set number
set scrolloff=3 " keep three lines between the cursor and the edge of the screen
set showcmd
set showmatch
set splitright
set splitbelow
set updatetime=100 " signify - async time reset
set wrapscan  " begin search from top of file when nothing is found anymore

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

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
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
