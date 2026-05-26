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
        pkgs.fish
        pkgs.zsh
        pkgs.inshellisense
      ];

      # Multishell completion engine
      programs.carapace = enabled;

      programs.nushell.environmentVariables = {
        CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
      };
    }
  ];
}
