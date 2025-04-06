setlocal colorcolumn=80
let &l:commentstring='// %s'

cnoreabbrev <buffer> <expr> cargo (getcmdtype() ==# ':' && getcmdline() =~# '^cargo') ? 'Cargo' : 'cargo'
