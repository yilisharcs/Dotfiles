syn match gitLogLine /^[_\*|\/\\ ]\+\(\<\x\{4,40\}\>.*\)\?$/
syn match gitLogHead /^[_\*|\/\\ ]\+\(\<\x\{4,40\}\> - ([^)]\+)\( ([^)]\+)\)\? \)\?/ contained containedin=gitLogLine
syn match gitLogDate /(\d\{4\}-\d\{2\}-\d\{2\})/ contained containedin=gitLogHead nextgroup=gitLogRefs skipwhite
syn match gitLogRefs /([^)]*)/ contained containedin=gitLogHead
syn match gitLogGraph /^[_\*|\/\\ ]\+/ contained containedin=gitLogHead,gitLogCommit nextgroup=gitHashAbbrev skipwhite
syn match gitLogCommit /^[^-]\+- / contained containedin=gitLogHead nextgroup=gitLogDate skipwhite
syn match gitLogIdentity /<[^>]*>$/ contained containedin=gitLogLine
hi def link gitLogGraph Comment
hi def link gitLogDate gitDate
hi def link gitLogRefs Type
hi def link gitLogIdentity gitIdentity
