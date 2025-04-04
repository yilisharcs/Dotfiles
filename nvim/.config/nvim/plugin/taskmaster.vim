" Search task file
function! GrepTodo(...)
    let g:GrepTodo = a:000

    if empty(a:000)
        let s:cmd = join([&grepprg] + ['@.*$', '~/notes/todo.md'], ' ')
    else
        let s:cmd = join([&grepprg] + a:000 + ['~/notes/todo.md'], ' ')
    endif

    return system(s:cmd)
endfunction

" Prepend to task list
function! GrepToAdd(...)
    return system('sed -i "1s/^/- @' . join(a:000, ' ') . '\n/" ~/notes/todo.md')
endfunction

" Delete task by index
function! GrepToDone(...)
    return system('sed -i "' . join(a:000, ' ') . 'd" ~/notes/todo.md')
endfunction

command! -nargs=* GrepTodo cexpr GrepTodo(<f-args>)
command! -nargs=+ GrepToAdd cgetexpr GrepToAdd(<f-args>)
command! -nargs=+ GrepToDone cgetexpr GrepToDone(<f-args>)

cnoreabbrev <expr> todo (getcmdtype() ==# ':' && getcmdline() =~# '^todo') ? 'GrepTodo' : 'todo'
cnoreabbrev <expr> toad (getcmdtype() ==# ':' && getcmdline() =~# '^toad') ? 'GrepToAdd' : 'toad'
cnoreabbrev <expr> tone (getcmdtype() ==# ':' && getcmdline() =~# '^tone') ? 'GrepToDone' : 'tone'

augroup Taskmaster
    au!
    au QuickFixCmdPost cexpr cwindow
                \| call setqflist([], 'a', {'title': ':' . s:cmd})
    " This refreshes the qflist whenever a task is added or removed
    au User TaskMaster execute 'GrepTodo '..join(g:GrepTodo, ' ')
    au QuickFixCmdPost cgetexpr silent! doau User TaskMaster
augroup END
