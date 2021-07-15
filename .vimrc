syntax enable
colorscheme monokai
set number
set showcmd
set cursorline
set lazyredraw
set showmatch
set autochdir


set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

set clipboard^=unnamed,unnamedplus
set encoding=utf-8
set nocompatible
set noswapfile

set ignorecase
set nowrap
set scrolloff=3 " keep three lines between the cursor and the edge of the screen
set wrapscan  " begin search from top of file when nothing is found anymore

set splitright
set splitbelow

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


set updatetime=100 " signify - async time reset
if executable('ag')
	  let g:ackprg = 'ag --vimgrep'
endif

"leader changed to space
nnoremap <SPACE> <Nop>
map <Space> <Leader>
nnoremap <leader>u :GundoToggle<CR>
nnoremap <leader>s :mksession<CR>
nnoremap <leader>tag :TagbarToggle<CR>
nnoremap <Leader>a :Ack!<Space>

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
