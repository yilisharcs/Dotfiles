;; extends

; Below is something I disapprove:
;
;   Treesitter
;     - @string.just links to String        priority: 90    language: just
; --> - @variable.just links to @variable   priority: 100   language: just
;     - @string.bash links to String        priority: 100   language: bash
;
;   Treesitter
;     - @string.just links to String                 priority: 90    language: just
; --> - @keyword.directive.just links to Statement   priority: 100   language: just
;     - @operator.c links to Operator                priority: 100   language: c
;
; @_.just variables should have higher priority than @string._ variables to be highlighted properly

(value
  (identifier) @variable
  (#set! priority 110))

((shebang) @keyword.directive
  (#set! priority 110))
