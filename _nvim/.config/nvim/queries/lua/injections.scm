;; extends

; comment-annotated language injection
;   `-- rust` before `[[...]]`
((comment) @injection.language
  .
  [
    (string
      content: (string_content) @injection.content)
    (expression_list
      value: (string
        content: (string_content) @injection.content))
  ] @_str
  (#lua-match? @_str "^%[%[")
  (#gsub! @injection.language "^%-%-%s*([%w_]+)%s*$" "%1")
  (#set! injection.combined))
