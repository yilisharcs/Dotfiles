{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.host = {
    touchpad = {
      enable = mkEnableOption "touchpad";
      name = mkOption {
        type = types.str;
        description = "Touchpad device name as reported by the kernel.";
      };
      vendorId = mkOption {
        type = types.str;
        description = "Touchpad vendor ID (hex, 4 digits).";
      };
      productId = mkOption {
        type = types.str;
        description = "Touchpad product ID (hex, 4 digits).";
      };
    };

    sddm.enable = mkEnableOption "SDDM display manager";

    # tmux-only at this time
    battery.enable = mkEnableOption "battery status in status bars";

    ghostty.fontSize = mkOption {
      type = types.int;
      description = "Set font size for Ghostty.";
    };
  };

  config = {
    services.libinput.enable = config.host.touchpad.enable;
  };
}
