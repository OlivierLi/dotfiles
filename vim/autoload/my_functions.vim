if exists("g:loaded_my_functions")
  finish
endif
let g:loaded_my_functions = 1

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

