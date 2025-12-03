if exists("b:current_syntax")
        finish
endif

syn clear

" Head w/ error type
syn match qfType       "^[EWI]\ze|"           nextgroup=qfSeparator1
syn match qfSeparator1 "|"          contained nextgroup=qfFileWError
syn match qfFileWError "[^|]*\ze|"  contained nextgroup=qfSeparator2

" Head w/o error type
syn match qfFileName "^\%\([EWI]|\)\@![^|]*\ze|" nextgroup=qfSeparator2

" Shared tail
syn match qfSeparator2 "|"         contained nextgroup=qfLineNr
syn match qfLineNr     "[^|]*\ze|" contained nextgroup=qfSeparator3
syn match qfSeparator3 "|"         contained nextgroup=qfText
syn match qfText       ".*"        contained

hi def link qfType       Type
hi def link qfFileName   Normal
hi def link qfFileWError Normal
hi def link qfLineNr     String
hi def link qfText       Directory
hi def link qfSeparator1 Delimiter
hi def link qfSeparator2 Delimiter
hi def link qfSeparator3 Delimiter

let b:current_syntax = "qf"

" vim: ts=8
