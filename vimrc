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
Bundle 'lyuts/vim-rtags'
Bundle 'Valloric/YouCompleteMe'
Bundle 'rdnetto/YCM-Generator'
Bundle 'scrooloose/nerdtree'
Bundle 'christoomey/vim-tmux-navigator'
Bundle 'kien/ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Bundle 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'

call vundle#end()

"Airline stuff
set noshowmode
set laststatus=2
:let g:airline_theme='understated'

"Tmux navigator stuff
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-A>h :TmuxNavigateLeft<cr>
nnoremap <silent> <C-A>j :TmuxNavigateDown<cr>
nnoremap <silent> <C-A>k :TmuxNavigateUp<cr>
nnoremap <silent> <C-A>l :TmuxNavigateRight<cr>
nnoremap <silent> <C-A>\ :TmuxNavigatePrevious<cr>

"YCM settings
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1


"Hardtime settings
let g:hardtime_default_on = 1
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 4
let g:list_of_normal_keys = ["h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>", "w", "W", "b", "B"]
let g:list_of_visual_keys = ["h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>", "w", "W", "b", "B"]

"Gitgutter stuff
let g:gitgutter_map_keys = 0

"Nerdtree stuff
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

syntax on
filetype plugin indent on
set t_Co=256
colorscheme wombat

set nocompatible

"Indent stuff
set expandtab
set tabstop=4
set shiftwidth=4

"Don't treat the hash is a special case when indenting
set cindent
set cinkeys-=0#
set indentkeys-=0#

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

"Split related behavior
set splitbelow
set splitright
autocmd VimResized * wincmd =

"Misc
set ignorecase
set smartcase
set ruler
set nowrap
set number
set relativenumber
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

"Autoclose QuickFix window if it's the last window
aug QFClose
    au!
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"|q|endif
aug END

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
