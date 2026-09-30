{
  self,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) disabled filterAttrs isType mapAttrs;
in {
  nix.channel = disabled;

  nix.registry =
    inputs
    |> filterAttrs (_: isType "flake")
    |> (r: r // {default = inputs.nixpkgs;})
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
        reo = "nh os boot ~/Dotfiles --accept-flake-config";
        ret = "nh os test ~/Dotfiles --accept-flake-config";
      };
    }
  ];
}
