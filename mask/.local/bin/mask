#!/usr/bin/env nu

# Search up the directory tree for
# a maskfile.md and execute it
def --wrapped main [...rest] {
        let cmd = (
                if ($rest | is-empty) {
                        ["_default"]
                } else {
                        $rest
                }
        )

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
                mask-bin ...$cmd
        } else {
                mask-bin --maskfile ([$path "maskfile.md"] | path join) ...$cmd
        }
}
