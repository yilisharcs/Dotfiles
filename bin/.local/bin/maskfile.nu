#!/usr/bin/env nu

# Search up the directory tree for
# a maskfile.md and execute it
def --wrapped main [...rest] {
  mut path = pwd
  while not (
    [$path "maskfile.md"]
    | path join
    | path exists
  ) {
    # Necessary to avoid an endless loop
    if ($path == "/") { break }
    $path = ($path
      | path split
      | drop
      | path join)
  }

  if ($path == "/") {
    mask ...$rest
  } else {
    mask --maskfile ([$path "/maskfile.md"] | str join) ...$rest
  }
}
