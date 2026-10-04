{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
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

  config = mkIf (!config.host.touchpad.enable) {
    # plasma-manager's "Enabled" touchpad key does nothing for SDDM. so just kill the device ig.
    services.udev.extraRules =
      /*
      udev
      */
      ''
        ACTION=="add|change", KERNEL=="event[0-9]*", \
        ATTRS{id/vendor}=="${config.host.touchpad.vendorId}", \
        ATTRS{id/product}=="${config.host.touchpad.productId}", \
        ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
  };
}
