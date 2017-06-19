call plug#begin('~/.vim/plugged')
" My bundles here:
" original repos on GitHub

if !&diff
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang', 'for': ['cpp', 'python'] }
    Plug 'scrooloose/nerdtree'
    Plug 'kien/ctrlp.vim'
    Plug 'junegunn/vim-peekaboo'
    Plug 'airblade/vim-gitgutter'
    Plug 'mileszs/ack.vim'
endif

Plug 'scrooloose/nerdcommenter'
Plug 'takac/vim-hardtime'
Plug 'lyuts/vim-rtags' , { 'for': 'cpp' }
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-dispatch'
Plug 'kshenoy/vim-signature'
Plug 'Valloric/ListToggle'
Plug 'junegunn/vim-peekaboo'
call plug#end()

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

"Only applicable when vim-rtags not loaded
nnoremap <leader>rj :YcmCompleter GoToDefinition<CR>
nnoremap <leader>rf :YcmCompleter GoToReferences<CR>

"Make stuff
nnoremap <leader>b :Make<CR>
cabbrev make Make 
set autowrite

"Dispatch stuff
nnoremap <leader>d :Dispatch<CR>

"Ack stuff
"Don't open the first result automatically
cabbrev ack Ack!

"Hardtime settings
let g:hardtime_default_on = 1
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 4
let g:list_of_normal_keys = ["h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>", "w", "W", "b", "B"]
let g:list_of_visual_keys = ["h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>", "w", "W", "b", "B"]

"Rtags stuff
let g:rtagsUseLocationList = 0

" Always have quickfix take the entire bottom of the screen
au FileType qf wincmd J

" peekaboo stuff 
let g:peekaboo_prefix = '<leader>'

"Gitgutter stuff
let g:gitgutter_map_keys = 0
nmap <Leader>hn  :GitGutterNextHunk<cr>
nmap <Leader>hp  :GitGutterPrevHunk<cr>
nmap <Leader>hu  :GitGutterUndoHunk<cr>
nmap <Leader>hs  :GitGutterStageHunk<cr>

"Nerdtree stuff
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
noremap <Leader>t :NERDTreeToggle<cr>
noremap <Leader>o :NERDTreeFind<cr>
let NERDTreeMapHelp='<f1>'

syntax on
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

" Don't add the comment prefix when I hit enter or o/O on a comment line.
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"Key remaps
noremap zk zt
noremap zj zb
nnoremap Q <nop>

"Produce the oposite effect from J
nnoremap K i<CR><Esc>

"Tab navigation
nnoremap <S-tab> :tabnext<CR>
nnoremap <C-S-tab> :tabprevious<CR> 

" Quit everything!
noremap <C-q> :qa!<CR>

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

"Disabble X clipboard for faster boot
set clipboard=exclude:.*

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

"Find out how many cores to use for make
function! SetMakeprg()
    if filereadable('/proc/cpuinfo')
        " this works on most Linux systems
        let n = system('grep -c ^processor /proc/cpuinfo') + 0
    else
        " default to single process if we can't figure it out automatically
        let n = 1
    endif
    
    " Don't go overboard on shared boxes
    if n > 8
        let n = 11
    endif

    let &makeprg = 'make' . (n > 1 ? (' -j'.(n + 1)) : '')
endfunction
call SetMakeprg()

" Additional color settings specifically for diff
highlight DiffText   cterm=bold ctermfg=7 ctermbg=56

" Used to collapse all blocks in a vimdiff
function CollapseAllBlocks()
    " Only search the unfolded areas
    set diffopt=filler,context:0
    set fdo-=search
endfunction
noremap <C-c> :call CollapseAllBlocks()<CR>

"TODO : Specialize the collpase function to handle non-diff mode
