let s:save_cpo = &cpo
set cpo&vim

let s:source = {
  \ 'name' : 'wikipedia',
\}

let s:util = call('unite#sources#wikipedia#util#import', [])

function! s:source.gather_candidates(args, context) "{{{
  let s:commands = s:get_commands()
  return map(s:commands, '{
\   "word"   : v:val,
\   "source" : s:source.name,
\   "description" : s:source.name,
\   "kind"   : "source",
\   "action__source_name" : "wikipedia/" . v:val,
\ }')
endfunction "}}}


" local functions {{{
function! s:get_commands() "{{{
  return map(
\   split(
\     globpath(&runtimepath, 'autoload/unite/sources/wikipedia/command/*.vim'),
\     '\n'
\   ),
\   'fnamemodify(v:val, ":t:r")'
\ )
endfunction "}}}

function! unite#sources#wikipedia#define()
  let sources = []
  for command in s:get_commands()
    let source = call('unite#sources#wikipedia#command#' . command . '#define', [])
    if type({}) == type(source)
      call add(sources, source)
    elseif type([]) == type(source)
      call extend(sources, source)
    endif
    unlet source
  endfor
  return add(sources, s:source)
endfunction

function! unite#sources#wikipedia#open_wikipedia(str)
  let l:wikiurl = s:util.get_wiki_domain() . "/wiki/" . a:str
  let l:run = exists('g:wikipedia_run_type') ? g:wikipedia_run_type : 'terminal'
  let l:cmd = exists('g:wikipedia_run_cmd') ? g:wikipedia_run_cmd : 'lynx'
  let l:option = exists('g:wikipedia_run_option') ? g:wikipedia_run_option : '"%s"'
  if executable(l:cmd)
    execute printf(join([l:run, l:cmd, l:option], " "), l:wikiurl) 
  else
    call unite#print_message("can't execute " . l:cmd)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

