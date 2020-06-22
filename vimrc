" Environment checks============================================================
if v:version < 801
  echoerr "Vim version >= 8.1 is needed!"
endif

if !executable('rg')
  echoerr "Ripgrep not installed on machine!"
endif

if !executable('bat')
  echoerr "BatCat not installed on machine!"
endif

" Plugins=======================================================================
call plug#begin('~/.vim/plugged')

if !&diff
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clangd-completer', 'for': ['cpp', 'python'] }
    Plug 'scrooloose/nerdtree'
    Plug 'junegunn/vim-peekaboo'
    Plug 'mhinz/vim-signify'
endif

Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'aklt/plantuml-syntax'
Plug 'benmills/vimux'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/async.vim'
Plug 'sjl/gundo.vim'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'olivierli/nerdcommenter'
Plug 'takac/vim-hardtime'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'kshenoy/vim-signature' " Handle markers in the gutter
Plug 'rhysd/vim-llvm'
call plug#end()

" Variables======================================================================

let g:goToFirst = 1 " Controls whether <C-j> should take you to the first or next result
let g:quickFixSize = 8 

" Keep track of the last time a buffer was viewed.
let g:buffer_access_times = {}

" Autocmds=======================================================================

augroup vimrc

    " Update buffer acces times.
    autocmd BufWinEnter, WinEnter * let g:buffer_access_times[bufnr('')] = localtime() " bufnr('') because these are windows events 
    autocmd BufDelete * silent! call remove(g:buffer_access_times, expand('<abuf>')) " <abuf> because the buffer is closed and <abuf> is the effective buffer

    " Always have quickfix take the entire bottom of the screen
    autocmd FileType qf wincmd J

    " Some command should only open from editable buffers.
    autocmd CmdlineLeave * call my_functions#MoveToValidWindowAfterCommand()

    " The quickfix window will open when an async job finishes.
    autocmd User AsyncRunStart call BeforeAsynCommand()

    " Remove the useless item for quickfix list
    autocmd User AsyncRunStop  call AfterAsyncCommand()

    " Don't add the comment prefix when I hit enter or o/O on a comment line.
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

    " The vimsplits should stay proportional through resizes
    autocmd VimResized * wincmd =

    " Open nerdtree on empty dirs and don't let it be the last window
    "autocmd VimEnter * if exists(":NERDTree") && argc() == 0 && !exists("s:std_in") | NERDTree | endif
    "autocmd StdinReadPre * let s:std_in=1
    "autocmd VimEnter * if exists(":NERDTree") && argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
    "autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif "winnr("$) for index of bottom right window

    " QuickFix autocmds
    autocmd FileType qf nnoremap <buffer> s :call OpenQF("vnew")<cr>
    autocmd FileType qf nnoremap <buffer> t :call OpenQF("tabedit")<cr>

    " Always show the gutter
    autocmd BufRead,BufNewFile * setlocal signcolumn=yes

    "autocmd VimEnter * call navigation#test()

augroup END

" Functions======================================================================
function! StripLeadingWhiteSpace(string)
 return substitute(a:string, '^\s*', '', '')
endfunction

" Remove and/or show trailing whitespace in the full buffer.
function StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    " Mark where we are in document.
    normal mz
    " Go to top of page and mark.
    normal Hmy
    " Remove trailing whitespace
    %s/\s\+$//e
    " Go back to previous top of page and bring it back to top of viewport.
    normal 'yz<CR>
    " Remove mark.
    normal my
    " Go back to previous position.
    normal `z
    " Remove mark.
    normal mz
  endif
endfunction

" Call the provided function after moving to a valid window.
function! InFirstValid(cmd)
  call my_functions#GoToFirstValid()
  execute a:cmd
endfunction

" Open the qf item under the cursor in the new space created with a:cmd
function! OpenQF(cmd)
  let l:qf_idx = line('.')
  call my_functions#GoToFirstValid()
  execute a:cmd
  execute l:qf_idx . 'cc'
endfunction

function! IsQFOpened()
  for winnr in range(1, winnr('$'))
    if getwinvar(winnr, '&syntax') == 'qf'
      return 1
    endif
  endfor

  return 0
endfunction

function! BeforeAsynCommand()
    " We have new content in the quickFix. We whould start from the beginning
    let g:goToFirst=1
    exec 'botright copen ' . g:quickFixSize
    call my_functions#GoToQF()
endfunction

function! AfterAsyncCommand()
    " Remove the first entry which is just a print of the command
    call setqflist(my_functions#Pop(getqflist(),0))
    " Remove the last entry which is just the time it took to execute
    call setqflist(my_functions#Pop(getqflist(), getqflist({'size': 1}).size-1))
endfunction

" Treat enter normally but change qf expectations if in qf
function! Enter()
    if &buftype ==# 'quickfix'
        let g:goToFirst=0
    endif
    execute "normal! \<CR>"
endfunction

function! GetValidQFEntries()
  " Only keep valid entries. (Those that match with erroformat)
  return filter(getqflist(), 'v:val.valid')
endfunction

"Go to the next element of interest, infer what that is from context
function! CNext()

    if IsQFOpened() && len(GetValidQFEntries()) != 0
      call my_functions#GoToFirstValid()

      if g:goToFirst
          exec('cfirst')
          let g:goToFirst=0
      else
          try | cnext | catch | cfirst | catch | endtry
      endif

      return
    endif

    "Go to next diff or to next signify hunk depending on mode.
    execute "normal ]c"

endfunction

"Go to the previous element of interest, infer what that is from context
function! CPrev()

    if IsQFOpened() && len(GetValidQFEntries()) != 0
      call my_functions#GoToFirstValid()

      " Detect end of list errors and loop around
      try | cprev | catch | clast | catch | endtry

      return
    endif

    " Go to previous diff or to previous signify hunk depending on mode
    execute "normal [c"

endfunction

" Find out how many cores to use for make
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

if getcwd() =~ ".*/chromium/src" 
  let &makeprg = "autoninja -C out/Default"
endif

" Used to collapse all blocks in a vimdiff
function CollapseAllBlocks()
    " Only search the unfolded areas
    set diffopt=filler,context:0
    set foldopen-=search
endfunction
noremap <silent> <leader>c :call CollapseAllBlocks()<CR>

" The rest =====================================================================

" Vimux stuff
let g:VimuxOrientation = "h"
autocmd VimEnter * call VimuxOpenRunner()
" TODO: Command to send visual selection
" TODO: Set br command : call VimuxSendText("br " . expand("%") . ":" .  getpos('.')[1])
nnoremap <silent> <C-s><C-s> :call VimuxSendText(StripLeadingWhiteSpace(getline('.')))<cr>

nnoremap <silent> <leader>xp :wa <bar> call VimuxPromptCommand()<cr>
nnoremap <silent> <leader>xx :wa <bar> call VimuxRunLastCommand()<cr>
nnoremap <silent> <leader>xc :call VimuxInterruptRunner()<cr>
nnoremap <silent> <leader>xt :wa <bar> call VimuxRunCommand(my_functions#GetTestCommand())<cr>
nnoremap <silent> <leader>xl :call my_functions#RunVimuxCommandNoHistory("clear")<cr>

" Signify stuff
let g:signify_update_on_focusgained=1 " Update VCS marks when focus gained
nmap <Leader>hd  :SignifyHunkDiff<cr>
nmap <Leader>hu  :SignifyHunkUndo<cr>
nmap <Leader>hs  :SignifyHunkUndo<cr>

" Airline stuff
set noshowmode
set laststatus=2

" Tmux navigator stuff
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-A>h :TmuxNavigateLeft<cr>
nnoremap <silent> <C-A>j :TmuxNavigateDown<cr>
nnoremap <silent> <C-A>k :TmuxNavigateUp<cr>
nnoremap <silent> <C-A>l :TmuxNavigateRight<cr>
nnoremap <silent> <C-A>\ :TmuxNavigatePrevious<cr>

" YCM settings
set completeopt-=preview " Don't show the autocomplete results in the preview window.
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_global_ycm_extra_conf = "~/git/dotfiles/ycm_extra_conf.py"
let g:ycm_auto_hover=''
let g:ycm_clangd_args = ['--background-index=false']

" Disable auto-closing of QuickFix when selecting result.
autocmd User YcmQuickFixOpened autocmd! ycmquickfix WinLeave
" Always open the QuickFix with the same size.
autocmd User YcmQuickFixOpened exec('copen ' . g:quickFixSize)

nnoremap <C-F> :YcmCompleter GoToDefinition<CR>
nnoremap <leader>rf :YcmCompleter GoToReferences<CR>
nnoremap <leader>f :YcmCompleter FixIt<CR>

" Gundo stuff
noremap <Leader>g :GundoToggle<cr>
if has('python3')
    let g:gundo_prefer_python3 = 1          " anything else breaks on Ubuntu 16.04+
endif

" fzf stuff
noremap <silent> <C-b> :call InFirstValid("Buffers")<CR>
noremap <silent> <C-t> :call InFirstValid("Files")<CR>
noremap <silent> <C-h> :call InFirstValid("History")<CR>

" Define a command for command abbreviations and use it.
command -nargs=+ CommandCabbr call my_functions#CommandCabbr(<f-args>)
CommandCabbr ack AsyncRun\ rg\ --vimgrep
CommandCabbr gd Gvdiffsplit
CommandCabbr gdm Gvdiffsplit\ 

" Hardtime settings
let g:hardtime_default_on = 1
let g:hardtime_allow_different_key = 0
let g:hardtime_maxcount = 8
let g:list_of_normal_keys = ['x', 'h', 'j', 'k', 'l', '-', '+', '<UP>', '<DOWN>', '<LEFT>', '<RIGHT>', 'w', 'W', 'b', 'B']
let g:list_of_visual_keys = ['h', 'j', 'k', 'l', '-', '+', '<UP>', '<DOWN>', '<LEFT>', '<RIGHT>', 'w', 'W', 'b', 'B']

" Rtags stuff
let g:rtagsUseLocationList = 0

" Quickfix and AsyncRun stuff vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

" Quickfix related remaps
nmap <silent> <Leader>q :call asyncrun#quickfix_toggle(10)<cr>
nmap <silent> <Leader>Q :colder<cr>
nmap <silent> <Leader>W :cnewer<cr>
nnoremap <leader>b :AsyncRun -program=make @<CR>
noremap <silent> <C-c> :AsyncStop<CR>

" Navigate the results without losing focus
noremap <silent> <C-j> :call CNext()<cr>zz
noremap <silent> <C-k> :call CPrev()<cr>zz

" Quickfix stuff ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

" Peekaboo stuff
let g:peekaboo_prefix = '<leader>'

" Nerdtree stuff
noremap <Leader>t :NERDTreeToggle<cr>
noremap <Leader>o :NERDTreeFind<cr>
let g:NERDTreeMapJumpNextSibling = '<Nop>'
let g:NERDTreeMapJumpPrevSibling = '<Nop>'
let g:NERDTreeMapHelp='<f1>'
let g:NERDTreeMapQuit ='<Nop>'

" Color stuff
syntax on

if (has("termguicolors"))
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  let g:dracula_italic = 0
  colorscheme dracula
  let g:airline_theme='dracula'
  set fillchars+=vert:│
else
  set t_Co=256
  colorscheme wombat
  :let g:airline_theme='understated'
endif

" Indent stuff
set expandtab
set tabstop=2
set shiftwidth=2

" Don't treat the hash is a special case when indenting
set cindent
set cinkeys-=0#
set indentkeys-=0#

" Use smart indenting when starting a new line.
set smartindent

" Key remaps
noremap zk zt
noremap zj zb
nnoremap Q <nop>
nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <CR> :call Enter()<CR>

" Comment aware merge and split
nnoremap J :call MergeUp()<CR>
nnoremap K :call SplitDown()<CR>

" Tab navigation
nnoremap <C-tab> :tabnext<CR>
nnoremap <C-S-tab> :tabprevious<CR>

" Quit everything!
noremap <C-q> :qa!<CR>

" Use more intuitive binding for scrolling
map <C-L> 20zl " Scroll 20 characters to the right
map <C-H> 20zh " Scroll 20 characters to the left

" Disable arrows
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Split related behavior
set splitbelow
set splitright

" Misc
set ignorecase
set smartcase
set ruler
set nowrap
set number
set relativenumber
set incsearch
set backspace=2
set modelines=0

" Disabble X clipboard for faster boot
set clipboard=exclude:.*

" Set to auto read when a file is changed from the outside
set autoread

" Set autowrite to avoid having to save everything before building
set autowrite

" Use Unix as the standard file type
set fileformats=unix,dos,mac

set encoding=utf-8

" Toggle auto-indenting for code paste
set pastetoggle=<F2>

" Display incomplete commands
set showcmd

" Autocomplete like bash
set wildmenu
set wildmode=list:longest

" Assume typist is reasonably fast and terminal is very fast
set timeoutlen=1000 ttimeoutlen=10

" Also save with capital W
command W w
command Wq wq
command WQ wq
command Q q
command Qa qa
command QA qa

" Use persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

