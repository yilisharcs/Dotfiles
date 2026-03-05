{ lib, stdenv, fetchzip }:

let
    dir = ./.;
    allFiles = builtins.readDir dir;
    pluginFiles = lib.filterAttrs (name: type: 
        type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
    ) allFiles;
in
    lib.mapAttrs' (name: _: 
        lib.nameValuePair 
            (lib.removeSuffix ".nix" name) 
            (import (dir + "/${name}") { inherit stdenv fetchzip; })
    ) pluginFiles
