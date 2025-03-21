("text" @number
  (#set! priority 130)
  (#lua-match? @number "^#[0-9]+$"))
