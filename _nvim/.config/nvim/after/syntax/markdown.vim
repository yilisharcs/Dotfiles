syn match TextInQuoteMarks /\v"([^"\\]|\\.)*"/
syn match UserHandle /\v(^|\s)\zs\@\w*/

hi! link TextInQuoteMarks String
hi UserHandle guifg=#87ffff

" A single `syn match` doesn't work without `syn clear`
syn region Tafsk_Wrapper matchgroup=Identifier start="\CTASK(" end=")" contains=Tafsk_HUID containedin=ALL
syn match Tafsk_HUID "\v\d{8}-\d{6}\.\w{8}" contained

hi def link Tafsk_HUID Constant
