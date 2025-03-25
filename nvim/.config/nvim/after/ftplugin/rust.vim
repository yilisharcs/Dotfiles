setlocal colorcolumn=80
let &l:commentstring='// %s'

hi link rsScalar @type.builtin

match rsScalar /\v(\d|_)@<=(f(32|64)|[ui](8|16|32|64|128|size))/
