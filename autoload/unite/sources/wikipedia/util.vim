let s:save_cpo = &cpo
set cpo&vim

let s:source = {
  \ 'name' : 'wikipedia/Util',
\}

function! unite#sources#wikipedia#util#define() 
  return s:source
endfunction

let s:util = {}

function! unite#sources#wikipedia#util#import()
  return s:util
endfunction

function! s:util.get_wiki_domain()
  return exists('g:wikipedia_domain') ? g:wikipedia_domain : "https://en.wikipedia.org"
endfunction

function! s:util.query(str) 

  let l:search_text = s:util.url_encode(a:str)
  let l:wikiurl = s:util.get_wiki_domain() . "/w/api.php?format=json&action=query&list=search&srlimit=50&srsearch=" . l:search_text
  
  let l:cmd = 'curl -q -s ' . "'" .l:wikiurl . "'"
  
  silent let l:res = system(l:cmd)
  unlet l:cmd

  if len(l:res) == 0
    return []
  endif
  
  let l:json = json_decode(l:res)
  let l:searchList = l:json["query"]["search"]
  
  call unite#print_message(l:json["query"]["searchinfo"]["totalhits"] . " hits")

  unlet l:json
  return map(l:searchList, '{"title": v:val["title"], "desc": v:val["snippet"]}')

endfunction

function! s:util.get_selected_text()
  let [l:l_start, l:c_start] = getpos("'<")[1:2]
  let [l:l_end, l:c_end] = getpos("'>")[1:2]

  let l:lines = getline(l:l_start, l:l_end)
  if len(l:lines) == 0
      return ''
  endif

  let l:lines[-1] = l:lines[-1][: l:c_end - (&selection == 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:c_start - 1:]
  return join(l:lines, "\n")
endfunction

function! s:char2hex(c)
  if a:c =~# '^[:cntrl:]$' | return '' | endif
  let r = ''
  for i in range(strlen(a:c))
    let r .= printf('%%%02X', char2nr(a:c[i]))
  endfor
  return r
endfunction

function! s:util.url_encode(text)
  return substitute(a:text, '[^0-9A-Za-z-._~!''()*#$&+,/:;=?@]',
        \ '\=s:char2hex(submatch(0))', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
