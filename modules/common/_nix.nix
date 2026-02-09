{ self, lib, pkgs, ... }: let
    inherit (lib) disabled;
in {
    nix.channel = disabled;

    nix.gc = {
        automatic  = true;
        dates      = "weekly";
        options    = "--delete-older-than 14d";
        persistent = true;
    };

    nix.optimise.automatic = true;

    nix.settings = (import <| self + /flake.nix).nixConfig;

    environment.systemPackages = [
        pkgs.nh
        pkgs.nix-index
        pkgs.nix-output-monitor
    ];

    home-manager.sharedModules = [{
        home.shellAliases = {
            reb = "nh os switch ~/Dotfiles --accept-flake-config";
        };
    }];
}
