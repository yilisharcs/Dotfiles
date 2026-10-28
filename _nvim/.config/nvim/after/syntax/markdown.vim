syn match TextInQuoteMarks /\v"([^"\\]|\\.)*"/
syn match UserHandle /\v(^|\s)\zs\@\w*/

hi! link TextInQuoteMarks String
hi UserHandle guifg=#87ffff
