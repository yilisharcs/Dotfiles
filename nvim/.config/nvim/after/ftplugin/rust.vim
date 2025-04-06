setlocal colorcolumn=80
let &l:commentstring='// %s'

cnoreabbrev <buffer> <expr> cargo (getcmdtype() ==# ':' && getcmdline() =~# '^cargo') ? 'Cargo' : 'cargo'

augroup Rust_C_Plug
    au!
    " Jump to errors; requires vim-sneak
    au TermOpen *:cargo\ * nmap <buffer> - s->
augroup END
