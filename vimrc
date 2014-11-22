set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My bundles here:
" original repos on GitHub
Bundle 'tpope/vim-surround'
Bundle 'airblade/vim-gitgutter'
Bundle 'ervandew/supertab'
Bundle 'Raimondi/delimitMate'

syntax on
filetype plugin indent on
set t_Co=256
colorscheme ir_black

set nocompatible
"Indent stuff
set expandtab
set tabstop=4
set shiftwidth=4
" Use indent from current line when starting a new one.
set autoindent
" Use smart indenting when starting a new line.
set smartindent

"Key remaps
noremap <Space> <PageDown>
nnoremap <tab> %
vnoremap <tab> %
"Use more intuitive binding for page-{up,down}
noremap <C-j> <C-f>
noremap <C-k> <C-b>

"Misc
set ignorecase
set smartcase
set ruler
set nowrap
set number
set incsearch

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
