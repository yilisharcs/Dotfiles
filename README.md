# .dotfiles

This repo houses my dotfiles. The nix pill sucks.

# TODO

- [ ] Figure out where to put these:
    * [ ] `gnome-keyring-daemon --replace --components=ssh,secrets,pkcs11`. If ssh isn't included, the agent will ask for the password every login.

# MASKFILE RULES

This section contains commands for the task runner **mask**.

## stow

> Create symlinks

This accepts an `adopt` flag due to certain files being completely
overwritten if modified externally, listed below:

- mimetype/.config/mimeapps.list
- qBittorrent/.config/qBittorrent/qBittorrent.conf
- syncthing/.local/state/syncthing/config.xml
- wallpaper/.config/background

**OPTIONS**
* adopt
    * flags: -a --adopt
    * desc: Adopt contents of conflicting files

* delete
    * flags: -d --delete
    * desc: Remove symlinks

```nu
let fold_dir = [
    "git"
    "mask"
    "neovim-config"
]

ls
| where type == dir
| where name !~ "^_"
| where not ($fold_dir | any {|pat| $it.name == $pat })
| get name
| if ($env.delete? | is-not-empty) {
    each { stow -D $in }
    stow -D ...$fold_dir
} else if ($env.adopt? | is-not-empty) {
    each { stow -R --no-folding --adopt $in }
} else {
    each { stow -R --no-folding $in }
    stow -R ...$fold_dir
}

print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"
```

## sudo

> Create system-wide symlinks

```nu
ls
| where type == dir
| where name =~ "^_"
| get name
| each { sudo stow -R --target=/ $in }

print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"
```
