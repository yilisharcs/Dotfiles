#!/usr/bin/env nu

tokei --hidden --compact --sort code
| lines
| where $it !~ "━"
| str trim
| split column --regex '\s\s+'
| rename ...($in | first | values)
| skip 1
| drop
| update Code {|e| $e.Code | into int }
| do {
  let total = ($in | get Code | math sum)
  $in | insert Percent {|e| ($e.Code * 100 / $total)}
}
| where Code > 0
| select Language Code Percent
