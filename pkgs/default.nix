{ pkgs, lib }: let
    inherit (lib) filterAttrs mapAttrs;

    loadPackages = type:
        let
            dir = ./${type};
        in
            mapAttrs
                (name: _: pkgs.callPackage (dir + "/${name}/package.nix") { })
                (filterAttrs (name: value: value == "directory") (builtins.readDir dir));

    loadModules = type: module:
        let
            dir = ./${type};
            fileName = "${module}.nix";
            dirs = filterAttrs (name: value: value == "directory") (builtins.readDir dir);
            withModule = filterAttrs (name: _: builtins.pathExists (dir + "/${name}/${fileName}")) dirs;
        in
            mapAttrs (name: _: import (dir + "/${name}/${fileName}")) withModule;

    games  = loadPackages "games";
    # Add more categories as needed:
    tools  = loadPackages "tools";
    # themes = loadPackages "themes";

in games // tools // {
    homeModules = loadModules "games" "home" // loadModules "tools" "home";
}
