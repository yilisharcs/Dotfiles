if exists("b:current_syntax")
        finish
endif

" TODO: currently missing highlights for divergence

" starts with graph connectors, no commit markers
syn region jjMessageLine start=/^[│├─╮╯~ ]\+/ end=/$/

" starts with optional connectors then @, ○, ◆, or ×
" defined AFTER jjMessageLine so it wins when both match at column 0
syn region jjCommitLine start=/^[│ ]*[○◆@×]/ end=/$/

" catch-all defined first so specific patterns after it win
syn match jjTag /\S\+/ contained containedin=jjCommitLine

" commit markers
syn match jjAt        /@/ contained containedin=jjCommitLine
syn match jjMutable   /○/ contained containedin=jjCommitLine
syn match jjImmutable /◆/ contained containedin=jjCommitLine
syn match jjConflict  /×/ contained containedin=jjCommitLine

" graph connectors
syn match jjConnector /[│├─╮╯~]/ contained containedin=jjCommitLine,jjMessageLine

" metadata (specific patterns win over jjTag defined above)
syn match jjHiddenUid   /[a-z]\{8\}\ze\//                           contained containedin=jjCommitLine
syn match jjUid         /[a-z]\{8\}\%(\/\)\@!/                      contained containedin=jjCommitLine
syn match jjGeneration  /\/\d\+/                                    contained containedin=jjCommitLine
syn match jjEmail       /\S\+@\S\+\.\S\+/                           contained containedin=jjCommitLine
syn match jjDate        /\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}/ contained containedin=jjCommitLine
syn match jjHash        /\x\{8\}/                                   contained containedin=jjCommitLine

" descriptors
syn match jjEmpty        /(empty)/              contained containedin=jjMessageLine
syn match jjNoDesc       /(no description set)/ contained containedin=jjMessageLine
syn match jjConflictDesc /(conflict)/           contained containedin=jjCommitLine,jjMessageLine
syn match jjHidden       /(hidden)/             contained containedin=jjCommitLine,jjMessageLine
syn match jjElided       /(elided revisions)/   contained containedin=jjMessageLine

" file status (summary)
syn match jjFileAdded    /A / contained containedin=jjMessageLine
syn match jjFileDeleted  /D / contained containedin=jjMessageLine
syn match jjFileModified /M / contained containedin=jjMessageLine
syn match jjFileRenamed  /R / contained containedin=jjMessageLine

hi def link jjAt           jjGreen
hi def link jjUid          jjMagenta
hi def link jjHiddenUid    jjWhite
hi def link jjGeneration   jjGrey
hi def link jjEmail        jjYellow
hi def link jjDate         jjCyan
hi def link jjHash         jjBlue
hi def link jjConflict     jjRed
hi def link jjMutable      Delimiter
hi def link jjImmutable    Special
hi def link jjConnector    Delimiter
hi def link jjTag          jjMagenta
hi def link jjEmpty        jjGreen
hi def link jjNoDesc       jjYellow
hi def link jjConflictDesc jjRed
hi def link jjHidden       jjWhite
hi def link jjElided       jjGrey
hi def link jjFileAdded    jjGreen
hi def link jjFileDeleted  jjRed
hi def link jjFileModified jjCyan2
hi def link jjFileRenamed  jjCyan2

let b:current_syntax = "jj"
