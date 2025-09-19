#!/usr/bin/env nu

# This script is necessary to force compatibility
# between vim-grepper/:grep and vim-symlink
def --wrapped main [...rest] {
        rg --vimgrep --no-follow ...$rest
        | lines
        | split column :
        | update column1 { realpath $in }
        | each { $in | values | str join ':' }
        | to text
}
