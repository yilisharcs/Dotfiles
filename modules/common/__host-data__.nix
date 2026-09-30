{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.host = {
    touchpad.enable = mkEnableOption "touchpad";

    sddm.enable = mkEnableOption "SDDM display manager";

    ghostty.fontSize = mkOption {
      type = types.int;
      description = "Set font size for Ghostty.";
    };
  };

  config = {
    services.libinput.enable = config.host.touchpad.enable;
  };
}
