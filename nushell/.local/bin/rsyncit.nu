#!/usr/bin/env nu

# Path: /media/yilisharcs/Cosmo
let hdd = (
  lsblk --json --output MOUNTPOINTS
  | from json
  | get blockdevices.mountpoints
  | flatten
  | where $it =~ Cosmo
  | get 0
)

let destdir = ([$hdd BACKUP $env.USER] | path join)
mkdir $destdir

[
  ".config"
  ".gnupg"
  ".ssh"
  "Documents"
  "Dotfiles"
  "Downloads"
  "Games"
  "Library"
  "Music"
  "notebook"
  "Pictures"
  "Projects"
  "vault"
  "Videos"
  ".bash_history"
  ".wget-hsts"
] | each {
  ([$env.HOME $in] | path join)
  | rsync --archive $in $destdir
} | ignore

print $"(ansi green_bold)Backup complete.(ansi reset)"
