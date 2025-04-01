" syn match sadly doesn't override fugitive defaults
match fugitiveAdded /^A /
2match fugitiveModified /^M /
3match fugitiveDeleted /^D /

hi def link fugitiveAdded Added
hi def link fugitiveModified Changed
hi def link fugitiveDeleted Removed

hi fugitiveUntrackedHeading gui=bold
hi fugitiveStagedHeading gui=bold
hi fugitiveUnstagedHeading gui=bold
