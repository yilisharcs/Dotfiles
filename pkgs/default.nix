{
  pkgs,
  lib,
}: let
  inherit (lib) filterAttrs mapAttrs;

  loadPackages = type: let
    dir = ./${type};
  in
    builtins.readDir dir
    |> filterAttrs (name: value: value == "directory")
    |> mapAttrs (name: _: pkgs.callPackage (dir + "/${name}/package.nix") {});

  loadModules = type: module: let
    dir = ./${type};
    fileName = "${module}.nix";
  in
    builtins.readDir dir
    |> filterAttrs (name: value: value == "directory")
    |> filterAttrs (name: _: builtins.pathExists (dir + "/${name}/${fileName}"))
    |> mapAttrs (name: _: import (dir + "/${name}/${fileName}"));

  games = loadPackages "games";
  # Add more categories as needed:
  tools = loadPackages "tools";
  # themes = loadPackages "themes";
in
  games
  // tools
  // {
    homeModules = loadModules "games" "home" // loadModules "tools" "home";
  }
