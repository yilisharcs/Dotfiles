#!/usr/bin/env nu

use std/dirs

let repos = (try {
  ls -a **/.git
  | get name
  | each {
    path split
    | drop
    | path join
  }
} catch {
  print $"(ansi red_bold)fatal: not a git repository \(or any of the parent directories\): .git(ansi reset)"
  return
})

let git_status = ($repos | each {|repo|
  dirs add $repo
  let git = (git status -s
    | split row "\n"
    | where { $in != "" })
  {
    "Path": $repo, "Status": ($git
      | if $in == [] {
        $"(ansi green_bold)OK(ansi reset)"
      } else {
        $in
      })
  }
})

$git_status | if ($in | length) > 1 {
  insert is_empty {|row| $row.Status == $"(ansi green_bold)OK(ansi reset)" }
  | sort-by is_empty
  | reject is_empty
} else {
  reject Path
  | flatten
}
