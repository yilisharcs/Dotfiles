{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    ({config, ...}: {
      programs.fightcade = enabled {
        package = pkgs.fightcade.override {
          firejailProfile = ./fightcade.profile;
        };
        dataDir = "${config.home.homeDirectory}/Games/Fightcade";
        autoDownloadROMs = true;
        sf3TrainingMode = true;
      };
    })
  ];
}
