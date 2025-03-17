" https://www.reddit.com/r/vim/comments/i2x8xc/i_want_gf_to_create_files_if_they_dont_exist/g07imjj/
"
function! s:open_file_or_create_new() abort
    let l:path=expand('<cfile>')
    if empty(l:path)
        return
    endif
    " Resolve <cfile> by filetype
    if &ft=='lua'
        let l:path=tr(l:path,'.','/')
    endif

    try
        exec 'norm! gf'
    catch /.*/
        echo '[New file]'
        lua vim.fn.timer_start(3000, function() print(" ") end)

        " Best used with "mini.misc".setup_auto_root({ ... }) or equivalent
        if &ft=='lua'
            let s:lua_env=finddir('lua', '.;')
            if !empty(s:lua_env)
                let l:new_path = getcwd()..'/'..s:lua_env..'/'..l:path
            endif
        else
            let l:new_path=fnamemodify(expand('%:p:h') . '/' . l:path, ':p')
        endif

        if !empty(fnamemodify(l:new_path, ':e')) " Edit immediately if file has extension
            return execute('edit '.l:new_path)
        endif

        let l:suffixes = split(&suffixesadd, ',')

        for l:suffix in l:suffixes
            if filereadable(l:new_path.l:suffix)
                return execute('edit '.l:new_path.l:suffix)
            endif
        endfor

        try
            return execute('edit '.l:new_path.l:suffixes[0])
        catch /.*/
            redraw
            echohl ErrorMsg | echo "Couldn't create file: &suffixesadd is empty." | echohl None
            lua vim.fn.timer_start(3000, function() print(" ") end)
        endtry
    endtry
endfunction

nnoremap <silent> gf <CMD>call <SID>open_file_or_create_new()<CR>
