{ pkgs, ... }:

let
    builder = pkgs.callPackage ../sonic3air/base.nix { };
in

builder {
    pname = "sonic3air-beta";
    version = "24.12.05.0-test";

    src = pkgs.fetchzip {
        url = "https://github.com/Eukaryot/sonic3air/releases/download/v24.12.05.0-test/sonic3air_game.tar.gz";
        hash = "sha256-eu6gXdnqqjRVrejY/PfdHJPuF3xHhFjwYvXoqpe3w4M=";
    };

    description = "Sonic 3 A.I.R. (BETA) - A fan-made widescreen remaster of Sonic 3 & Knuckles";
    desktopName = "Sonic 3 A.I.R. (BETA)";
}
