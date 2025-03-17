if expand('%:e')!='lemon'
    setlocal colorcolumn=80
endif

setlocal noexpandtab
setlocal iskeyword+='
let &l:commentstring='// %s'
