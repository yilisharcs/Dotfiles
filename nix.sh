#!/usr/bin/env bash
set -euo pipefail

sudo nixos-rebuild switch                       \
        --flake github:yilisharcs/Dotfiles#ouro \
        --option extra-experimental-features "nix-command flakes pipe-operators"
