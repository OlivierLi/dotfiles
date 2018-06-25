call plug#begin('~/.vim/plugged')

if !&diff
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang', 'for': ['cpp', 'python'] }
    Plug 'scrooloose/nerdtree'
    Plug 'junegunn/vim-peekaboo'
    Plug 'airblade/vim-gitgutter'
endif

Plug 'skywind3000/asyncrun.vim'
Plug 'sjl/gundo.vim'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'scrooloose/nerdcommenter'
Plug 'takac/vim-hardtime'
Plug 'lyuts/vim-rtags' , { 'for': 'cpp' }
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'kshenoy/vim-signature' " Handle markers in the gutter
Plug 'rhysd/vim-clang-format'
Plug 'rhysd/vim-llvm'
call plug#end()

"Variables======================================================================

let g:goToFirst=1 " Controls whether <C-j> should take you to the first or next result

"Autocmds=======================================================================

augroup vimrc

    " Always have quickfix take the entire bottom of the screen
    au FileType qf wincmd J

    " The quickfix window will open when an async job finishes.
    autocmd User AsyncRunStart call BeforeAsynCommand()
    
    " Remove the useless item for quickfix list
    autocmd User AsyncRunStop  call AfterAsyncCommand()

    " Don't add the comment prefix when I hit enter or o/O on a comment line.
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    
    " The vimsplits should stay proportional through resizes
    autocmd VimResized * wincmd =

    " Open nerdtree on empty dirs and don't let it be the last window
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif "winnr("$) for index of bottom right window

augroup END

"Functions======================================================================

function! IsWinValid(win_num)
    let bnum = winbufnr(a:win_num) " Get the buffer number associated with window
    if bnum != -1 && getbufvar(bnum, '&buftype') ==# '' " If the buffer has a buftype it's probably owned by a plugin
                \ && getbufvar(bnum, "&buftype") != "quickfix"
                \ && !getwinvar(a:win_num, '&previewwindow')
            return 1
    endif
    return 0
endfunction

function! GetNextValid()
    let i = 1
    while i <= winnr('$') " Iterate until the number of the last window
        if IsWinValid(l:i)
            return l:i
        endif

        let i += 1
    endwhile
    return -1
endfunction

" Jump to the next valid window, prioritize the previous window
function! GoToFirstValid()

    " If in a valid window do nothing
    if IsWinValid(winnr())
        return
    endif

    " If the previous window was valid prioritize it
    let last_index = winnr('#')
    if IsWinValid(l:last_index)
        exec(l:last_index. 'wincmd w')
        return
    endif

    let l:i = GetNextValid()
    if l:i != -1
        exec(l:i. 'wincmd w')
    endif
endfunction

function! Pop(l, i)
    let new_list = deepcopy(a:l)
    call remove(new_list, a:i)
    return new_list
endfunction

function! BeforeAsynCommand()
    " We have new content in the quickFix. We whould start from the beginning
    let g:goToFirst=1
    call asyncrun#quickfix_toggle(8, 1)
endfunction

function! AfterAsyncCommand()
    " Remove the first entry which is just a print of the command
    call setqflist(Pop(getqflist(),0))
    " Remove the last entry which is just the time it took to execute
    call setqflist(Pop(getqflist(), getqflist({'size': 1}).size-1))
endfunction

" Treat enter normally but change qf expectations if in qf
function! Enter()
    if &buftype ==# 'quickfix'
        let g:goToFirst=0
    endif
    execute "normal! \<CR>"
endfunction

"The rest =====================================================================

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
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0

"Only applicable when vim-rtags not loaded
nnoremap <C-F> :YcmCompleter GoToDefinition<CR>
nnoremap <leader>rf :YcmCompleter GoToReferences<CR>

"Gundo stuff
noremap <Leader>g :GundoToggle<cr>
if has('python3')
    let g:gundo_prefer_python3 = 1          " anything else breaks on Ubuntu 16.04+
endif

" Commands abbreviations
cabbrev ack AsyncRun ag --vimgrep

"Hardtime settings
let g:hardtime_default_on = 1
let g:hardtime_allow_different_key = 0
let g:hardtime_maxcount = 8
let g:list_of_normal_keys = ['x', 'h', 'j', 'k', 'l', '-', '+', '<UP>', '<DOWN>', '<LEFT>', '<RIGHT>', 'w', 'W', 'b', 'B']
let g:list_of_visual_keys = ['h', 'j', 'k', 'l', '-', '+', '<UP>', '<DOWN>', '<LEFT>', '<RIGHT>', 'w', 'W', 'b', 'B']

"Rtags stuff
let g:rtagsUseLocationList = 0
nnoremap <silent> <C-F> :call rtags#JumpTo(g:SAME_WINDOW)<CR>

" Quickfix and AsyncRun stuff vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

" quickfix related remaps
nmap <silent> <Leader>q :call asyncrun#quickfix_toggle(10)<cr>
nmap <silent> <Leader>Q :colder<cr>
nmap <silent> <Leader>W :cnewer<cr>
nnoremap <leader>b :AsyncRun -program=make @<CR>
noremap <silent> <C-c> :AsyncStop<CR>

" Detect end of list errors and loop around
command Cprev try | cprev | catch | clast | catch | endtry

function! CNext()
    if g:goToFirst
        exec('cfirst')
        let g:goToFirst=0
        return
    endif
        try | cnext | catch | cfirst | catch | endtry
endfunction

" Navigate the results without losing focus
noremap <silent> <C-j> :call CNext()<cr>zz
noremap <silent> <C-k> :Cprev<cr>zz

" quickfix stuff ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

" Always move to a valid window before calling a command
noremap :q :q
noremap : :call GoToFirstValid()<cr>:

" peekaboo stuff 
let g:peekaboo_prefix = '<leader>'

"Gitgutter stuff
let g:gitgutter_map_keys = 0
nmap <Leader>hn  :GitGutterNextHunk<cr>
nmap <Leader>hp  :GitGutterPrevHunk<cr>
nmap <Leader>hu  :GitGutterUndoHunk<cr>
nmap <Leader>hs  :GitGutterStageHunk<cr>

"Nerdtree stuff
noremap <Leader>t :NERDTreeToggle<cr>
noremap <Leader>o :NERDTreeFind<cr>
let g:NERDTreeMapJumpNextSibling = '<Nop>'
let g:NERDTreeMapJumpPrevSibling = '<Nop>'
let g:NERDTreeMapHelp='<f1>'
let g:NERDTreeMapQuit ='<Nop>'

syntax on
set t_Co=256
colorscheme wombat

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

"Key remaps
noremap zk zt
noremap zj zb
nnoremap Q <nop>
nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <CR> :call Enter()<CR>

"Produce the oposite effect from J
nnoremap K i<CR><Esc>

"Tab navigation
nnoremap <C-tab> :tabnext<CR>
nnoremap <C-S-tab> :tabprevious<CR> 

" Quit everything!
noremap <C-q> :qa!<CR>

"Use more intuitive binding for scrolling
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

" Set autowrite to avoid having to save everything before building
set autowrite

" Use Unix as the standard file type
set fileformats=unix,dos,mac

"Toggle auto-indenting for code paste
set pastetoggle=<F2>

"Display incomplete commands
set showcmd

"Autocomplete like bash
set wildmenu
set wildmode=list:longest

" Assume typist is reasonably fast and terminal is very fast
set timeoutlen=1000 ttimeoutlen=50

"Also save with capital W
command W w
command Wq wq
command WQ wq
command Q q
command Qa qa
command QA qa

"Use persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

"Find out how many cores to use for make
function! SetMakeprg()
    if filereadable('/proc/cpuinfo')
        " this works on most Linux systems
        let l:n = system('grep -c ^processor /proc/cpuinfo') + 0
    else
        " default to single process if we can't figure it out automatically
        let l:n = 1
    endif
    
    let &makeprg = 'make' . (l:n > 1 ? (' -j'.(l:n + 1)) : '')
endfunction
call SetMakeprg()

" Additional color settings specifically for diff
highlight DiffText   cterm=bold ctermfg=7 ctermbg=56

" Used to collapse all blocks in a vimdiff
function CollapseAllBlocks()
    " Only search the unfolded areas
    set diffopt=filler,context:0
    set foldopen-=search
endfunction
noremap <silent> <leader>c :call CollapseAllBlocks()<CR>
