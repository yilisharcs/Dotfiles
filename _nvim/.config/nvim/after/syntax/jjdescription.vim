" '%1' only the first line
syn match jjDashedKeyword       /\%1l\w\+\(-\w\+\)\+:/ contains=jjDashedDelimiter
syn match jjDashedDelimiter     /:/ contained

hi link jjDashedKeyword         @keyword.jjdescription
hi link jjDashedDelimiter       @punctuation.delimiter.jjdescription

hi link jjDashedKeyword @keyword.jjdescription
