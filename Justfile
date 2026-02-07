set shell               := ["nu", "-c"] # For single-line execution
set script-interpreter  := ["nu"]       # For bundled execution

# NOTE: Until Debian ships with `just 1.46.0`, it's wise to keep any of the
# attributes below commented out so the bootstrap script can work smoothly.
#       [default]
#       [arg("arg", pattern="|adopt|delete")]
#
# Create home-wide symlinks
[script]
stow arg="":
        let fold_dir = [
                "git"
                "neovim-config"
        ]

        ls
        | where type == dir
        | where name !~ "^_"
        | where not ($fold_dir | any {|pat| $it.name == $pat })
        | get name
        | if "{{arg}}" == "delete" {
                each { stow -D $in }
                stow -D ...$fold_dir
        } else if "{{arg}}" == "adopt" {
                # Some programs do not take kindly to writing to symlinked files and, to my eternal
                # chagrin, back them up and generate new files. These files then need to be adopted
                # by stow lest fall out of sync. Below is a non-comprehensive list of culprits:
                #
                #       mimetype/.config/mimeapps.list
                #       qBittorrent/.config/qBittorrent/qBittorrent.conf
                #       syncthing/.local/state/syncthing/config.xml
                each { stow -R --no-folding --{{arg}} $in }
                each { stow -R --no-folding $in } # `stow adopt` never seems to stow correctly!
        } else if "{{arg}}" == "" {
                each { stow -R --no-folding $in }
                stow -R ...$fold_dir
        }

        print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"


# [arg("arg", pattern="|adopt|delete")]
#
# Create system-wide symlinks
[script]
sudo arg="":
        ls
        | where type == dir
        | where name =~ "^_"
        | get name
        | if "{{arg}}" == "delete" {
                each { sudo stow -D $in }
        } else if "{{arg}}" == "adopt" {
                each { sudo stow -R --target=/ --{{arg}} $in }
                each { sudo stow -R --target=/ $in } # `stow adopt` never seems to stow correctly!
        } else {
                each { sudo stow -R --target=/ $in }
        }

        print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"

# It's not immediately obvious which files ought to be under version control. KDE is particularly
# annoying about this, putting configuration files everywhere... nothing inotifywait can't fix.
# NOTE: Brave dumps a lot of stuff in the .config folder, stuff that doesn't need to be there.
#
# Watch $XDG_CONFIG_HOME for file changes
watch:
        if ("watch.log" | path exists) { rm watch.log } # No copies
        inotifywait -mr ~/.config -e modify -e move -e create --exclude "BraveSoftware" o>> watch.log
