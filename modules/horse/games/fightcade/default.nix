{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) disabled;
in {
  home-manager.sharedModules = [
    ({config, ...}: {
      programs.fightcade = disabled {
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
