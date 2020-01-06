if exists("g:loaded_navigation")
  finish
endif
let g:loaded_navigation = 1

" Small utility functions ------------------------------------------------------
function! navigation#lesser_than(first, second)
  return a:first < a:second
endfunction

function! navigation#greater_than(first, second)
  return a:first > a:second
endfunction
" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

function! navigation#RangesOverlap(start1, end1, start2, end2)
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

" Retrieves all adjacent windows in |direction|.
function! navigation#GetWindows(direction)
  let l:adjacent_windows = []

  if(a:direction == "left")
    let l:SecondarySizeGetter = function('winheight')
    let l:Comparator = function('navigation#lesser_than')

    let l:main_measure_index = 1
    let l:secondary_measure_index = 0
  endif

  if(a:direction == "right")
    let l:SecondarySizeGetter = function('winheight')
    let l:Comparator = function('navigation#greater_than')

    let l:main_measure_index = 1
    let l:secondary_measure_index = 0
  endif

  " Windows with a lower y value.
  if(a:direction == "up")
    let l:SecondarySizeGetter = function('winwidth')
    let l:Comparator = function('navigation#lesser_than')

    let l:main_measure_index = 0
    let l:secondary_measure_index = 1
  endif

  " Windows with a higher y value.
  if(a:direction == "down")
    let l:SecondarySizeGetter = function('winwidth')
    let l:Comparator = function('navigation#greater_than')

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

    if navigation#RangesOverlap(l:self_secondary_measure , l:self_secondary_measure + l:SecondarySizeGetter(winnr()),
          \ l:win_secondary_measure, l:win_secondary_measure + l:SecondarySizeGetter(l:win))

      if(l:Comparator(l:win_main_measure , l:self_main_measure))
        call add(l:adjacent_windows, l:win)
      endif

    endif
  endfor

  return l:adjacent_windows
endfunction

" Sets up some windows and buffers to visually validate functions work.
function navigation#test()

  " First create splits with individual buffers
  exec('split 2')
  exec('vs 3')
  exec('split 4')
  exec('vs 5')

  " Then updates active buffers in windows with info on adjacent buffers.
  for l:win in range(1, winnr('$'))
    exec(l:win. 'wincmd w')
    call append(line('.'), "Window: ".winnr())
    normal! J
    normal o
    call append(line('.'), "Windows to the left: ".string(navigation#GetWindows("left")))
    call append(line('.'), "Windows to the right: ".string(navigation#GetWindows("right")))
    call append(line('.'), "Windows above: ".string(navigation#GetWindows("up")))
    call append(line('.'), "Windows under: ".string(navigation#GetWindows("down")))
    normal! J
  endfor

endfunction
