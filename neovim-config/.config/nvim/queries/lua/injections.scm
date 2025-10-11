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
