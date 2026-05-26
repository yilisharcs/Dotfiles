{
  self,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) disabled filterAttrs isType mapAttrs;
  registryMap = filterAttrs (_: isType "flake") inputs;
in {
  nix.channel = disabled;

  nix.registry =
    registryMap
    // {default = inputs.nixpkgs;}
    |> mapAttrs (_: flake: {inherit flake;});

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  nix.optimise.automatic = true;

  nix.settings = (import <| self + /flake.nix).nixConfig;

  environment.systemPackages = [
    pkgs.nh
    pkgs.nix-index
    pkgs.nix-output-monitor
  ];

  home-manager.sharedModules = [
    {
      home.shellAliases = {
        reb = "nh os switch ~/Dotfiles --accept-flake-config";
      };
    }
  ];
}
