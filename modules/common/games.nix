{ lib, pkgs, ... }: let
    inherit (lib) disabled enabled;
in {
    home-manager.sharedModules = [({ config, ... }: {
        programs.fightcade = enabled {
            dataDir = "${config.home.homeDirectory}/Games/Fightcade";
            autoDownloadROMs = true;
            sf3TrainingMode = true;
        };

        home.packages = [
            pkgs.mega-man-x8-16bit
            pkgs.sonic3air
            pkgs.sonic3air-beta
            pkgs.super-mario-63
        ];
    })];
}
