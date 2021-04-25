if exists("g:loaded_navigation")
  finish
endif
let g:loaded_navigation = 1

" Keep track of the last time a buffer was viewed.
let g:start_time = reltime()
let g:buffer_access_times = {}

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

  if(a:direction == "Left" || a:direction == "Right")
    let l:MainSizeGetter = function('winwidth')
    let l:SecondarySizeGetter = function('winheight')
    let l:main_measure_index = 1
    let l:secondary_measure_index = 0
  endif

  if(a:direction == "Up" || a:direction == "Down")
    let l:MainSizeGetter = function('winheight')
    let l:SecondarySizeGetter = function('winwidth')
    let l:main_measure_index = 0
    let l:secondary_measure_index = 1
  endif

  let l:self_main_measure = win_screenpos(0)[l:main_measure_index]
  let l:self_secondary_measure = win_screenpos(0)[l:secondary_measure_index]

  if(a:direction == "Left" || a:direction == "Up")
    " To know if two windows touch you need to get the edges of interest.
    " In these directions that's done by adding the main dimension on 
    " the secondary window and taking the primary as is.
    let l:Comparator = function('navigation#lesser_than')
  endif

  if(a:direction == "Right" || a:direction == "Down")
    " To know if two windows touch you need to get the edges of interest.
    " In these directions that's done by adding the primary dimension on 
    " the main window and taking the secondary as is.
    let l:Comparator = function('navigation#greater_than')
  endif

  " For every window.
  for l:win in range(1, winnr('$'))

    " Do not compare to self.
    if l:win == winnr() 
      continue
    endif

    let l:win_main_measure = win_screenpos(l:win)[l:main_measure_index]
    let l:win_secondary_measure = win_screenpos(l:win)[l:secondary_measure_index]

    " If windows don't overlap on their secodary dimension..
    if !navigation#RangesOverlap(l:self_secondary_measure , l:self_secondary_measure + l:SecondarySizeGetter(winnr()),
          \ l:win_secondary_measure, l:win_secondary_measure + l:SecondarySizeGetter(l:win))
      continue
    endif

    " If windows are not positioned correctly on their main position.
    if(!l:Comparator(l:win_main_measure , l:self_main_measure))
      continue
    endif

    if a:direction == "Left" || a:direction == "Up"
      let distance = abs(l:self_main_measure - l:win_main_measure - l:MainSizeGetter(l:win) ) 
      if distance != 1
        continue
      endif
    endif

    if a:direction == "Right" || a:direction == "Down"
      let distance = abs(l:self_main_measure + l:MainSizeGetter(winnr()) - l:win_main_measure)
      if distance != 1
        continue
      endif
    endif

    call add(l:adjacent_windows, win_getid(l:win))

  endfor

  return l:adjacent_windows
endfunction

function navigation#update_time()
  let g:buffer_access_times[win_getid(winnr())] = reltimefloat(reltime(g:start_time))
endfunction

function navigation#go(direction)
  let l:max_time = 0
  let l:window_to_go_to = -1 
  for l:win in navigation#GetWindows(a:direction)

    " Do not compare to self.
    if l:win == win_getid()
      continue
    endif

    " If for some reason the window was never registered ignore it.
    if !has_key(g:buffer_access_times, l:win)
      continue
    endif

    let l:access_time = g:buffer_access_times[l:win] 
    if l:access_time > l:max_time
      let l:max_time = l:access_time
      let l:window_to_go_to = l:win
    endif
  endfor

  if l:window_to_go_to != -1
    call win_gotoid(l:window_to_go_to)
  else
    execute "TmuxNavigate".a:direction
  endif

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

    " TODO: Make a function that gives you all for edges.
    " TODO: Print the size in x an y here to compare.
    "call append(line('.'), "Size (x): " . winwidth(winnr()))
    "call append(line('.'), "Size (y): " . winheight(winnr()))

    normal! J
    normal o
    call append(line('.'), "Windows to the left: ".string(navigation#GetWindows("Left")))
    call append(line('.'), "Windows to the right: ".string(navigation#GetWindows("Right")))
    call append(line('.'), "Windows above: ".string(navigation#GetWindows("Up")))
    call append(line('.'), "Windows under: ".string(navigation#GetWindows("Down")))
    normal! J
  endfor

endfunction
