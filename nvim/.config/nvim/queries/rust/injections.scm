(call_expression
  (field_expression
    value: (identifier) @_value (#eq? @_value "conn")
    field: (field_identifier) @_field (#match? @_field "^(execute|prepare)$"))

  (arguments
    (string_literal
      (string_content) @injection.content
      (#set! injection.language "sql"))))

(const_item
  name: (identifier) @_name (#match? @_name "^.*_SQL$")
  type: (reference_type
          type: (primitive_type) @_type (#eq? @_type "str"))
  value: (raw_string_literal
           (string_content) @injection.content
           (#set! injection.language "sql")))
