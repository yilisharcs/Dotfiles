{ pkgs, ... }:

let
    builder = pkgs.callPackage ./base.nix { };
in

builder {
    pname = "sonic3air";
    version = "24.02.02.1";

    src = pkgs.fetchzip {
        # Don't ask me why Euka didn't put the right link here
        url = "https://github.com/Eukaryot/sonic3air/releases/download/v24.02.02.0-stable/sonic3air_game.tar.gz";
        hash = "sha256-Sge/8vLTgGfwC120jRRkZAjPJJaMmabrUlrxXn3ROk4=";
    };

    description = "Sonic 3 A.I.R. - A fan-made widescreen remaster of Sonic 3 & Knuckles";
    desktopName = "Sonic 3 A.I.R.";
}
