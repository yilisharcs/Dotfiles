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
    # courtesy of HSVSphere. i'm sure he'd scalp me
    # for rewriting those nushell functions in bash
    (pkgs.writeShellScriptBin "nr" ''
      program="''${1:-}"
      shift 2>/dev/null || true
      if [[ "$program" == *#* ]] || [[ "$program" == *:* ]]; then
        nix run "$program" -- "$@"
      else
        nix run "default#$program" -- "$@"
      fi
    '')
    (pkgs.writeShellScriptBin "ns" ''
      packages=()
      for pkg in "$@"; do
        if [[ "$pkg" == *#* ]] || [[ "$pkg" == *:* ]]; then
          packages+=("$pkg")
        else
          packages+=("default#$pkg")
        fi
      done
      packages+=("default#bashInteractive")
      nix shell "''${packages[@]}" --command bash
    '')
    (pkgs.writeShellScriptBin "at" ''
      nix build "$HOME/Dotfiles#inputs.nixpkgs.legacyPackages.x86_64-linux.$1" --no-link --print-out-paths
    '')
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
