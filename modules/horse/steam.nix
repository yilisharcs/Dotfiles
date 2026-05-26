{lib, ...}: let
  inherit (lib) enabled;
in {
  programs.steam = enabled;
}
