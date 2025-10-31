;; extends

(assignment_statement
  (variable_list
    name: (identifier) @_var
    (#match? @_var "(query|parser_query|treesitter_query)"))
  (expression_list
    (string
      content: (string_content) @injection.content)
    ) @_str
  (#lua-match? @_str "^%[%[")
  (#set! injection.language "query"))

; rockspec
(assignment_statement
  (variable_list
    name: (identifier) @_build1
    (#match? @_build1 "^build$"))
    (expression_list
      (table_constructor
        (field
          name: (identifier) @_build2
          (#lua-match? @_build2 "^build_command$")
          value: (string
                   (string_content) @injection.content)
          (#set! injection.language "sh")))))
