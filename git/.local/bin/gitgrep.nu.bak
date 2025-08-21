#!/usr/bin/env nu

# Grep your codebase across its history
#
# `git grep <regexp> $(git rev-list --all)`
# This is my implementation of the bash snippet above. I
# made this because I must nurture my hatred of strings.
# Btw this returns json.
def main [...regexp: string] {
  let str = ($regexp | str join " ")

  git rev-list --all
  | lines
  | each {|e|
    git grep -I --heading --break --line-number --color=always -E $"($str)"
    | lines
    | if ($in | is-empty) {
      return null
    } else {
      $in
      | split list ""
      | each {
        match ($in | describe) {
          "list<string>" => {
            update 0 { "Path": $in.0 }
            | prepend { "Revision": $"(ansi yellow_bold)($e | str substring 0..7)(ansi reset)" }
            | each {
              match ($in | describe) {
                "string" => {
                  split row ":"
                  | {
                    ($in | get 0 | ansi strip):
                    ($in | get 1 | str substring 3..-1)
                  }
                },
                _ => { return $in }
              }
            }
          },
          _ => { return $in }
        }
        | reduce {|it| merge $it }
      }
    }
  }
  | to json
}
