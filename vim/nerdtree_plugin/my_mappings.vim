if exists("g:loaded_nerdtree_custom_maps")
  finish
endif
let g:loaded_nerdtree_custom_maps = 1

call NERDTreeAddKeyMap({
  \ 'scope': 'FileNode',
  \ 'key': 's',
  \ 'callback': 'NERDTreePlacedSplit',
  \ 'quickhelpText': 'open in bg tab and close tree' })

function NERDTreePlacedSplit(fnode)
  call my_functions#SetFirstValidAsPrevious()
  call a:fnode.activate({'where': 'v'})
endfunction
