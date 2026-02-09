;; extends

; tcc compiles so fast, one could use C as a scripting language
(recipe_body
  (shebang
    (language) @_lang)
  (#any-of? @_lang "tcc")
  (#set! injection.language "c")
  (#set! injection.include-children)) @injection.content
