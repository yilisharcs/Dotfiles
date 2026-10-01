#!/usr/bin/env bash
set -euo pipefail

# must run with `sudo` otherwise NIX_CONFIG isn't used
HOST="${1:?usage: sudo ./bootstrap.sh <hostname>}"

export NIX_CONFIG="experimental-features = nix-command flakes pipe-operators cgroups
accept-flake-config = true"

# format disk from nixos ISO
nix run github:nix-community/disko -- --mode destroy,format,mount --yes-wipe-all-disks --flake ".#${HOST}"
nixos-install --flake ".#${HOST}"

# after reboot:
#   - on HOST:
#     + `nmtui` (wifi secret is encrypted)
#     + `sudo rm -rf` any directory created as root by agenix.
#   - on PREV:
#     + `ssh-keygen -R {{HOST}}.local` (if needed)
#     + `just mirror {{HOST}} .ssh`
#     + `just mirror {{HOST}} Dotfiles`
#     + `just get-host-key {{HOST}}`
#     + paste key into lib/keys.nix, commit, rebuild
#     + `just rekey`
#     + commit, push
#   - on HOST:
#     + `cd Dotfiles && jj git fetch`
#     + `sudo nixos-rebuild switch --flake .#{{HOST}}`
