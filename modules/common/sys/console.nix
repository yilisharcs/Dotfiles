{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  # kernel VT
  console = enabled {
    earlySetup = true;
    font = "ter-228b";
    packages = [pkgs.terminus_font];
  };
}
