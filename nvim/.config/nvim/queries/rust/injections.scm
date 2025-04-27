(call_expression
  (field_expression
    value: (identifier) @_value (#eq? @_value "conn")
    field: (field_identifier) @_field (#match? @_field "^(execute|prepare)$"))

  (arguments
    (string_literal
      (string_content) @injection.content
      (#set! injection.language "sql")
      ))
  )
