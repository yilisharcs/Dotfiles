#!/usr/bin/env nu

$env.config.display_errors.termination_signal = false

# This script is necessary to force compatibility
# between vim-grepper/:grep and vim-symlink
def --wrapped main [...rest] {
        rg --vimgrep --no-follow ...$rest
        | lines
        | split column :
        | update column1 { realpath $in }
        | each { $in | values | str join ":" }
        | to text
}
