{lib, ...}: let
  inherit (lib) disabled;
in {
  # Screen reader
  services = {
    orca = disabled;
    speechd = disabled;
  };
}
