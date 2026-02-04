set shell               := ["nu", "-c"] # For single-line execution
set script-interpreter  := ["nu"]       # For bundled execution

# Create home-wide symlinks
[default]
[script]
[arg("arg", pattern="|adopt|delete")]
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
        } else if "{{arg}}" == "" {
                each { stow -R --no-folding $in }
                stow -R ...$fold_dir
        }

        print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"


# Create system-wide symlinks
[script]
[arg("arg", pattern="|adopt|delete")]
sudo arg="":
        ls
        | where type == dir
        | where name =~ "^_"
        | get name
        | if "{{arg}}" == "delete" {
                each { sudo stow -D $in }
        } else if "{{arg}}" == "adopt" {
                each { sudo stow -R --target=/ --{{arg}} $in }
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
        rm watch.log # No copies
        inotifywait -mr ~/.config -e modify -e move -e create --exclude "BraveSoftware" o>> watch.log
