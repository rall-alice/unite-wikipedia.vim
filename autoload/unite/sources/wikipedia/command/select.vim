let s:save_cpo = &cpo
set cpo&vim

let s:source = {
  \ 'name' : 'wikipedia/select',
  \ 'description' : 'search by selected text',
\}

let s:util = call('unite#sources#wikipedia#util#import', [])

function! s:source.gather_candidates(args, context)
  let l:selected = s:util.get_selected_text()
  if len(l:selected) == 0
    return []
  endif

  let l:search_list = s:util.query(l:selected)

  return map(l:search_list, '{
  \ "word" : v:val["title"],
  \ "source" : s:source.name,
  \ "kind": "command",
  \ "action__command": "call unite#sources#wikipedia#open_wikipedia(''".v:val["title"]."'')"
  \ }')
endfunction

function! unite#sources#wikipedia#command#select#define() 
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

