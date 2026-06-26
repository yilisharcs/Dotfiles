{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.bash
        pkgs.fish
        pkgs.zsh
        pkgs.inshellisense
      ];

      # Multishell completion engine
      programs.carapace = enabled;

      home.sessionVariables = {
        CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
      };
    }
  ];
}
