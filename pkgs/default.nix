{ pkgs, lib }: let
    inherit (lib) filterAttrs mapAttrs;

    loadPackages = type:
        let
            dir = ./${type};
        in
            mapAttrs
                (name: _: pkgs.callPackage (dir + "/${name}/package.nix") { })
                (filterAttrs (name: value: value == "directory") (builtins.readDir dir));

    games  = loadPackages "games";
    # Add more categories as needed:
    tools  = loadPackages "tools";
    # themes = loadPackages "themes";

in games // tools # // themes
