" Search task file
function! TaskList(...)
  let g:TaskList = a:000

  if empty(a:000)
    let s:cmd = join([&grepprg] + ['@.*$', '~/7vtlk-wj5qh/todo.md'], ' ')
  else
    let s:cmd = join([&grepprg] + a:000 + ['~/7vtlk-wj5qh/todo.md'], ' ')
  endif

  return system(s:cmd)
endfunction

" Prepend to task list
function! TaskAdd(...)
  return system('sed -i "1s^- @' . join(a:000, ' ') . '\n" ~/7vtlk-wj5qh/todo.md')
endfunction

" Remove from task list
function! TaskDone(...)
  let list = getloclist(0)
  " Line numbers directly correspond to 1-based index
  let idx = join(a:000, ' ') - 1

  if idx < 0 || idx >= len(list)
    echohl WarningMsg | echo 'E684: List index out of range: ' . idx | echohl None
    return
  else
    let text = list[idx].text
    echohl Type | echo "Task done: " . text | echohl None
    return system('sed -i "\' . text . 'd" ~/7vtlk-wj5qh/todo.md')
  endif
endfunction

command! -nargs=* TaskList lgetexpr TaskList(<f-args>)
command! -nargs=+ TaskAdd lgetexpr TaskAdd(<f-args>)
command! -nargs=+ TaskDone lgetexpr TaskDone(<f-args>)

cnoreabbrev <expr> todo (getcmdtype() ==# ':' && getcmdline() =~# '^todo') ? 'TaskList' : 'todo'
cnoreabbrev <expr> toad (getcmdtype() ==# ':' && getcmdline() =~# '^toad') ? 'TaskAdd' : 'toad'
cnoreabbrev <expr> tone (getcmdtype() ==# ':' && getcmdline() =~# '^tone') ? 'TaskDone' : 'tone'

augroup Taskmaster
  au!
  " Sets the loclist name with the grep cmd; errors if loclist is empty
  au QuickFixCmdPost lgetexpr lwindow | silent! call setloclist(0, [], 'a', {'title': ':' . s:cmd})
  " This refreshes the loclist whenever a task is added or removed
  " Call with silent! to suppress error if g:TaskList is empty
  au User TaskMaster silent! execute 'TaskList '..join(g:TaskList, ' ')
  au QuickFixCmdPost lgetexpr doau User TaskMaster
augroup END

function! ToggleLoclist()
  if empty(getloclist(0))
    echohl WarningMsg | echo 'Loclist is empty.' | echohl None
    return
  endif

  " The location list is oddly global. TODO: report to maintainers
  if empty(filter(getwininfo(), 'v:val.loclist'))
    botright lopen
  else
    lclose
  endif
endfunction
nnoremap co <CMD>call ToggleLoclist()<CR>
