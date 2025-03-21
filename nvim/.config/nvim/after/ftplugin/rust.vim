setlocal colorcolumn=80
let &l:commentstring='// %s'

hi rsScalar guifg=#fab387 gui=bold
match rsScalar /\d\@<=f\(32\|64\)/
2match rsScalar /\d\@<=u\(8\|16\|32\|64\|128\)/
