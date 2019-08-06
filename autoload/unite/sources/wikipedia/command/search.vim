let s:save_cpo = &cpo
set cpo&vim

let s:source = {
  \ 'name' : 'wikipedia/search',
  \ 'description' : 'search by last search text',
\}

let s:util = call('unite#sources#wikipedia#util#import', [])

function! s:source.gather_candidates(args, context)
  let l:searching_text = substitute(substitute(histget('/', -1),'\<' , '', 'g'),  '\>' , '', 'g')

  if strlen(l:searching_text) == 0
    return []
  endif
  
  let l:search_list = s:util.query(l:searching_text)

  return map(l:search_list, '{
  \ "word" : v:val["title"],
  \ "source" : s:source.name,
  \ "kind": "command",
  \ "action__command": "call unite#sources#wikipedia#open_wikipedia(''".v:val["title"]."'')"
  \ }')
endfunction

function! unite#sources#wikipedia#command#search#define() 
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

