#!/usr/bin/env nu

# Get help, with pagers!
#
# The default `help` command dumps information
# into the terminal with no regard for usability.
# This wrapper pipes any help output into `less`,
# or, if applicable, nushell's built-in `explore`.
def main [
  --find (-f): string  # string to find in command names, descriptions, and search terms
  ...arg: string
] {
  if not ($find | is-empty) {
    help --find $find | explore
    return
  }

  # `help` provides the subcommands below.
  # If not individually matched, they will
  # be interpreted as arguments and fail.
  match $arg {
    aliases => { help aliases | explore }
    commands => { help commands | explore }
    escapes => { help operators | explore }
    externs => { help externs | explore }
    modules => { help modules | explore }
    operators => { help operators | explore }
    pipe-and-redirect => { help pipe-and-redirect | explore }
    # Return the default help page
    null => { help | less -FRX }
    _ => { help ...$arg | less -FRX }
  }
}
