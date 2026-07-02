{
  lib,
  stdenv,
  fetchzip,
}: let
  dir = ./.;
in
  builtins.readDir dir
  |> lib.filterAttrs (
    name: type:
      type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
  )
  |> lib.mapAttrs' (
    name: _:
      lib.nameValuePair
      (lib.removeSuffix ".nix" name)
      (import (dir + "/${name}") {inherit stdenv fetchzip;})
  )
