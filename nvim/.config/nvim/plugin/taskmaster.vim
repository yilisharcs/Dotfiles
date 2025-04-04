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

" Remove from task list
function! GrepToDone(...)
    let list = getqflist()
    " Line numbers directly correspond to 1-based index
    let idx = join(a:000, ' ') - 1

    if idx < 0 || idx >= len(list)
        echohl WarningMsg | echo 'E684: List index out of range: ' . idx | echohl None
        return
    else
        let text = list[idx].text
        echohl ModeMsg | echo "Task done: " . text | echohl None
        return system('sed -i "/' . text . '/d" ~/notes/todo.md')
    endif
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
    " This refreshes the quickfix list whenever a task is added or removed
    au User TaskMaster execute 'GrepTodo '..join(g:GrepTodo, ' ')
    au QuickFixCmdPost cgetexpr silent! doau User TaskMaster
augroup END
