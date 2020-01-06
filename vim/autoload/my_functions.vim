if exists("g:loaded_my_functions")
  finish
endif
let g:loaded_my_functions = 1

function! my_functions#RangesOverlap(start1, end1, start2, end2)
  if (a:start1 >= a:start2 && a:start1 <= a:end2)
    return 1
  endif

  if (a:end1 >= a:start2 && a:end1 <= a:end2)
    return 1
  endif

  if (a:start2 >= a:start1 && a:start2 <= a:end1)
    return 1
  endif

  if (a:end2 >= a:start1 && a:end2 <= a:end1)
    return 1
  endif

  return 0
endfunction

function my_functions#lesser_than(first, second)
  return a:first < a:second
endfunction

function my_functions#greater_than(first, second)
  return a:first > a:second
endfunction

function my_functions#GetWindows(direction)
  let l:adjacent_windows = []


  if(a:direction == "left")
    let l:SecondaryMeasureGetter = function('winheight')
    let l:Comparator = function('my_functions#lesser_than')

    let l:main_measure_index = 1
    let l:secondary_measure_index = 0
  endif

  if(a:direction == "right")
    let l:SecondaryMeasureGetter = function('winheight')
    let l:Comparator = function('my_functions#greater_than')

    let l:main_measure_index = 1
    let l:secondary_measure_index = 0
  endif

  " Windows with a lower y value.
  if(a:direction == "up")
    let l:SecondaryMeasureGetter = function('winwidth')
    let l:Comparator = function('my_functions#lesser_than')

    let l:main_measure_index = 0
    let l:secondary_measure_index = 1
  endif

  " Windows with a higher y value.
  if(a:direction == "down")
    let l:SecondaryMeasureGetter = function('winwidth')
    let l:Comparator = function('my_functions#greater_than')

    let l:main_measure_index = 0
    let l:secondary_measure_index = 1
  endif

  let l:self_secondary_measure = win_screenpos(0)[l:secondary_measure_index]
  let l:self_main_measure = win_screenpos(0)[l:main_measure_index]

  for l:win in range(1, winnr('$'))

    " Do not compare to self.
    if l:win == winnr() 
      continue
    endif

    let l:win_secondary_measure = win_screenpos(l:win)[l:secondary_measure_index]
    let l:win_main_measure = win_screenpos(l:win)[l:main_measure_index]

    " TODO: Only count windows that "touch"
    " TODO: Generalize function to all directions

    if my_functions#RangesOverlap(l:self_secondary_measure , l:self_secondary_measure + l:SecondaryMeasureGetter(winnr()),
          \ l:win_secondary_measure, l:win_secondary_measure + l:SecondaryMeasureGetter(l:win))

      if(l:Comparator(l:win_main_measure , l:self_main_measure))
        call add(l:adjacent_windows, l:win)
      endif

    endif
  endfor

  return l:adjacent_windows
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
function! my_functions#GetTestCommand()
  "TODO : Warn of ignore DISABLED flag

  let l:current_line = getline(getpos('.')[1])

  " Sometimes the test name is on two lines
  if l:current_line !~ ".*{$"
    let l:second_line = substitute(getline(getpos('.')[1]+1), "^ *", "", "")
    let l:test_name = substitute(l:current_line . l:second_line , "\n", "", "")
  else
    let l:test_name = l:current_line
  endif

  " Remove everything before the class name
  let l:test_name = substitute(l:test_name, "^.*(","", "")
  " Separate by period instead of comma
  let l:test_name = substitute(l:test_name, ',', '.', '')
  " Remove stuff at the end
  let l:test_name = substitute(l:test_name, ').*', '', '')
  " Remove ALL spaces
  let l:test_name = substitute(l:test_name, ' ', '', '')

  " Choose the unit test target
  let l:full_path = expand('%')
  if l:full_path =~ "^base.*"
    let l:target = "base_unittests"
  elseif l:full_path =~ "^components.*"
    let l:target = "components_unittests"
  elseif l:current_line =~ "IN_PROC_BROWSER_TEST_F.*"
    let l:target = "browser_tests"
  else
    let l:target = "unit_tests"
  endif

  " TODO: running arguments : Add the correct \[0-9]+ or whatever for parametrized tests
  let l:command = "run_chrome_tests " .  l:target . " run " . l:test_name

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
