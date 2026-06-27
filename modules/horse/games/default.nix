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
        pkgs.mega-man-x8-16-bit
        pkgs.super-mario-63
      ];
    }
  ];
}
