setlocal nolist

call matchadd('fugitiveAdded', '^A ')
call matchadd('fugitiveModified', '^M ')
call matchadd('fugitiveDeleted', '^D ')

hi def link fugitiveAdded Added
hi def link fugitiveModified Changed
hi def link fugitiveDeleted Removed

hi fugitiveUntrackedHeading gui=bold
hi fugitiveStagedHeading gui=bold
hi fugitiveUnstagedHeading gui=bold
