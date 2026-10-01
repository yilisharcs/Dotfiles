set shell               := ["nu", "-c"] # For single-line execution
set script-interpreter  := ["nu"]       # For bundled execution

# Create home-wide symlinks
[script]
[default]
[arg("arg", pattern="|adopt|delete")]
stow arg="":
    ls
    | where type == dir
    | where name =~ "^_"
    | where name != "_nvim"
    | get name
    | if "{{arg}}" == "delete" {
        each { stow -D $in }
        stow -D "_nvim"
    } else if "{{arg}}" == "adopt" {
        # Some programs do not take kindly to writing to symlinked files and, to my eternal
        # chagrin, back them up and generate new files. These files then need to be adopted
        # by stow lest fall out of sync. Below is a non-comprehensive list of culprits:
        #
        #       _mimetype/.config/mimeapps.list
        #       _qBittorrent/.config/qBittorrent/qBittorrent.conf
        each { stow -R --no-folding --{{arg}} $in }
        each { stow -R --no-folding $in } # `stow adopt` never seems to stow correctly!
        stow -R _nvim
    } else if "{{arg}}" == "" {
        each { stow -R --no-folding $in }
        stow -R _nvim
    }

    print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"

# It's not immediately obvious which files ought to be under version control.
# NOTE: Brave dumps a lot of stuff in the .config folder, stuff that doesn't need to be there.
#
# Watch $XDG_CONFIG_HOME for file changes
watch:
    if ("watch.log" | path exists) { rm watch.log } # No copies
    inotifywait -mr ~/.config -e modify -e move -e create --exclude "BraveSoftware" o>> watch.log

# Build a package from the custom-packages
HOST := `hostname`

build name:
    nix build .#nixosConfigurations.{{HOST}}.pkgs.{{name}}

run name:
    ./result/bin/{{name}}

# Mirror files to a host via ssh.
[script]
mirror target paths="Dotfiles":
    tar -I zstd -cf - -C /home/yilisharcs {{paths}}
    | ssh {{target}}.local "cd /home/yilisharcs && rm -rf {{paths}} && tar -I zstd -xf -"

# Get a host's SSH public key (avahi allows {{target}}.local). Paste into "lib/keys.nix" after.
get-host-key target:
    ssh -o StrictHostKeyChecking=accept-new {{target}}.local "cat /etc/ssh/ssh_host_ed25519_key.pub"

# Re-encrypt agenix secrets with current host keys from "lib/keys.nix".
# Commit and push after. The machine whose host key was added must pull and rebuild.
rekey:
    agenix -r
