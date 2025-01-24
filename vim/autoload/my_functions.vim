if exists("g:loaded_my_functions")
  finish
endif
let g:loaded_my_functions = 1

" Opening the quickfix will start by going to the nearest window and then spliting.
" We don't want to update window visit times during that operation since the moves
" were not user initiated.
function my_functions#MyCopen(size)
    call navigation#suspend_time_updates()
    execute 'copen '. a:size
    call navigation#reinstante_time_updates()
    call navigation#update_time()
endfunction

" Self contained detection for closed windows. Navigates back to the most recent
" window when this is detected.
function! MyHandleWinClose()
  if get(t:, '_win_count', 0) > winnr('$')
    call navigation#go_back()
  endif
  let t:_win_count = winnr('$')
endfun
augroup vimrc_user
  au!
  au BufWinEnter,WinEnter,BufDelete * call MyHandleWinClose()
augroup END

function! my_functions#ToggleQuickFix()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    call my_functions#MyCopen(8)
  else
    cclose
  endif
endfunction

"Test whether a window is valid, that is to say whether it is suitable to open a file or not
function! my_functions#IsWinValid(win_num)
    let bnum = winbufnr(a:win_num) " Get the buffer number associated with window
    if bnum != -1 && getbufvar(bnum, '&buftype') ==# '' " If the buffer has a buftype it's probably owned by a plugin
                \ && getbufvar(bnum, "&buftype") != "quickfix"
                \ && !getwinvar(a:win_num, '&previewwindow')
            return 1
    endif
    return 0
endfunction

"Get the index of the first valid window
function! my_functions#GetNextValid()
    let i = 1
    while i <= winnr('$') " Iterate until the number of the last window
        if my_functions#IsWinValid(l:i)
            return l:i
        endif

        let i += 1
    endwhile
    return -1
endfunction

" Jump to the next valid window, prioritize the previous window
function! my_functions#GoToFirstValid()

    " If in a valid window do nothing
    if my_functions#IsWinValid(winnr())
        return
    endif

    " If the previous window was valid prioritize it
    let last_index = winnr('#')
    if my_functions#IsWinValid(l:last_index)
        exec(l:last_index. 'wincmd w')
        return
    endif

    let l:i = my_functions#GetNextValid()
    if l:i != -1
        exec(l:i. 'wincmd w')
    endif
endfunction

" Go directly to QF if opened
function! my_functions#GoToQF()
  for winnr in range(1, winnr('$'))
    let l:win_index = getwinvar(winnr, '&syntax')
    if l:win_index == 'qf'
        exec(l:winnr. 'wincmd w')
    endif
  endfor
endfunction

function! my_functions#MoveToValidWindowAfterCommand()
  let l:cmd = getcmdline()

  " Match the commands that should only be executed in a valid buffer.
  let regexes = ["e .*", ".* %", "vs.*"]

  for regex in regexes
    if l:cmd =~ regex
      call my_functions#GoToFirstValid()
    endif
  endfor
endfunc

"Make it so that toggling to last windows brings up the first valid window
function! my_functions#SetFirstValidAsPrevious()
  call my_functions#GoToFirstValid()
  let last_index = winnr('#')
  exec(l:last_index. 'wincmd w')
endfunction

"Remove the element i of a list and return a copy
function! my_functions#Pop(l, i)
    let new_list = deepcopy(a:l)
    call remove(new_list, a:i)
    return new_list
endfunction

" Function to get the test command for a Chromium test.
function! my_functions#GetTestCommand(mode)
  if a:mode == "line"
    let l:line_sub_command = " --line ". getpos('.')[1]
  else
    let l:line_sub_command = ""
  endif

  let l:command = "./tools/autotest.py -C out/Release " . expand('%:p') . " --no-try-android-wrappers" . l:line_sub_command
  return l:command
endfunction

" Generate commands abbreviations. Generated abbreviations verify that we are in the
" command line and that the replacement is applied at the start on execution.
function my_functions#CommandCabbr(abbreviation, expansion)
  execute 'cabbr ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
endfunction

" Init to empty to not get undefined warnings
let g:VimuxLastCommand = ""
function my_functions#RunVimuxCommandNoHistory(command)
  let l:backup = g:VimuxLastCommand
  call VimuxRunCommand(a:command)
  let g:VimuxLastCommand = l:backup
endfunction
