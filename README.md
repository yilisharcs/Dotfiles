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

```nu
ls
| where type == dir
| where name !~ "_"
| get name
| if $env.adopt? == "true" {
    each { stow -R --adopt $in }
} else {
    each { stow -R $in }
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

## ln

> Create non-stow symlinks and stow target directories

Some packages don't provide a conveniently-named binary.
Others need to be overridden due to desktop env constraints.
Some symlinks just need to exist. This script provides for all.

Also, `stow` symlinks whole dirs if they don't exist. Without the
second half of this script, the system will cram stuff where it
isn't supposed to go.

```nu
if not ("~/Extern-Media" | path exists) {
    ln -sf /media/yilisharcs ~/Extern-Media
}

print $"(ansi green_bold)Created symlinks.(ansi reset)"

mkdir ~/.config
mkdir ~/.local/bin
mkdir ~/.local/include
mkdir ~/.local/lib
mkdir ~/.local/share/icons/hicolor/128x128/apps
mkdir ~/.local/share/icons/hicolor/16x16/apps
mkdir ~/.local/share/icons/hicolor/24x24/apps
mkdir ~/.local/share/icons/hicolor/256x256/apps
mkdir ~/.local/share/icons/hicolor/32x32/apps
mkdir ~/.local/share/icons/hicolor/48x48/apps
mkdir ~/.local/share/icons/hicolor/64x64/apps
mkdir ~/.local/share/icons/hicolor/scalable/apps
mkdir ~/.local/share/man/man1
mkdir ~/.local/share/nvim/lazy
mkdir ~/.local/share/nvim/mason
mkdir ~/.local/state

print $"(ansi green_bold)Created stow target directories.(ansi reset)"
```
