set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My bundles here:
" original repos on GitHub
Bundle 'tpope/vim-surround'
Bundle 'airblade/vim-gitgutter'
Bundle 'jiangmiao/auto-pairs'
Bundle 'takac/vim-hardtime'

"Hardtime settings
let g:hardtime_default_on = 1
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 4

call vundle#end()

syntax on
filetype plugin indent on
set t_Co=256
colorscheme wombat

set nocompatible
"Indent stuff
set expandtab
set tabstop=4
set shiftwidth=4
" Use indent from current line when starting a new one.
set autoindent
" Use smart indenting when starting a new line.
set smartindent

" Look for tags starting at the current directory and all the way up to root
set tags=./tags;/

"Key remaps
noremap zk zt
noremap zj zb

"Tab navigation
nnoremap <S-tab> :tabnext<CR>
nnoremap <C-S-tab> :tabprevious<CR> 

"Use more intuitive binding for scrolling
noremap <C-j> <C-f>
noremap <C-k> <C-b>
map <C-L> 20zl " Scroll 20 characters to the right
map <C-H> 20zh " Scroll 20 characters to the left

"Disable arrows
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

"Misc
set ignorecase
set smartcase
set ruler
set nowrap
set number
set incsearch
set backspace=2

" Set to auto read when a file is changed from the outside
set autoread

" Use Unix as the standard file type
set ffs=unix,dos,mac

"Toggle auto-indenting for code paste
set pastetoggle=<F2>

"Display incomplete commands
set showcmd

"Easier hex editing
noremap <F8> :call HexMe()<CR>

"Autocomplete like bash
set wildmenu
set wildmode=list:longest

"Use persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

let $in_hex=0
function HexMe()
    set binary
    set noeol
if $in_hex>0
    :%!xxd -r
    let $in_hex=0
else
    :%!xxd
    let $in_hex=1
endif
endfunction
