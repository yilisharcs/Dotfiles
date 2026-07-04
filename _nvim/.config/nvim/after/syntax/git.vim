syn match gitLogLine /^[_\*|\/\\ ]\+\(\<\x\{4,40\}\>.*\)\?$/
syn match gitLogIdentity /<[^>]*>$/ contained containedin=gitLogLine
syn match gitLogHead /^[_\*|\/\\ ]\+\(\<\x\{4,40\}\> \[[^]]\+\]\( ([^)]\+)\)\? \)\?/ contained containedin=gitLogLine
syn match gitLogRefs /([^)]*)/ contained containedin=gitLogHead
syn match gitLogDate /\[\d\{4\}-\d\{2\}-\d\{2\}\]/ contained containedin=gitLogHead nextgroup=gitLogRefs skipwhite
syn match gitLogCommit /^[^-]\+- / contained containedin=gitLogHead nextgroup=gitLogDate skipwhite
syn match gitLogGraph /^[_\*|\/\\ ]\+/ contained containedin=gitLogHead,gitLogCommit nextgroup=gitHashAbbrev skipwhite
hi def link gitLogIdentity gitIdentity
hi def link gitLogRefs PreProc
hi def link gitLogDate FoldColumn
hi def link gitLogGraph Delimiter
hi link gitHashAbbrev Statement
