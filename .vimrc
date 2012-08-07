set nocompatible

filetype plugin on
filetype indent on

"Indent stuff
set expandtab
set tabstop=4
set shiftwidth=4
" Use indent from current line when starting a new one.
set autoindent
" Use smart indenting when starting a new line.
set smartindent

"Deactivate arrows to get used to hjkl
noremap  <Up> ""
noremap  <Down> ""
noremap  <Left> ""
noremap  <Right> ""

"Key remaps
noremap <Space> <PageDown>

"Misc
set ignorecase
set smartcase
set ruler
set nowrap
set number

" Set to auto read when a file is changed from the outside
set autoread

" Use Unix as the standard file type
set ffs=unix,dos,mac

"Toggle auto-indenting for code paste
set pastetoggle=<F2>

"Display incomplete commands
set showcmd