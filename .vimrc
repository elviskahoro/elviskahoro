set termguicolors
colorscheme monokai_pro

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
set termguicolors
set viewoptions-=options
set wildmenu
set wrapscan

filetype plugin on
syntax on

let mapleader = ";"

"netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 0
let g:netrw_winsize = 30

"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Lexplore
"augroup END
"
nnoremap - :Vexplore! %:p:h<CR>
"nnoremap <leader>dd :Lexplore %:p:h<CR>
"nnoremap <Leader>da :Lexplore<CR>

"remap world
nnoremap j gj
nnoremap k gk
nnoremap gV `[v`]
nnoremap dil ^d$

set hidden
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>

set incsearch
set laststatus=2
set noshowmode

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

