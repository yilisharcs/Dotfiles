{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled mkIf;

  libtsm' = pkgs.libtsm.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patch/libtsm/0001-Do-not-render-bold-as-bright.patch
      ];
  });
in {
  # kernel VT
  console = enabled {
    earlySetup = true;
    font = "ter-228b";
    packages = [pkgs.terminus_font];
  };

  # userspace KMS/DRM VT
  services.kmscon = enabled {
    package = pkgs.kmscon.override {libtsm = libtsm';};
    useXkbConfig = true;
    config =
      {
        hwaccel = config.hardware.graphics.enable;
        libseat = false; # NOTE: upstream defaults to false since 2026-06-30
        font-engine = "pango"; # NOTE: freetype doesn't currently support italics
        font-name = "IosevkaTermSlab Nerd Font Mono"; # NOTE: non-mono nerd glyphs can be cut in half
        font-size = 22;
        session-control = true;
        sb-size = 10000;
        bell = true;
        mouse = false;
        xkb-repeat-delay = 300;
      }
      // lib.colors.toKmsconPalette lib.colors.silverwine;
  };

  environment.shellAliases = mkIf config.services.desktopManager.plasma6.enable {
    kmscon-startplasma = "kmscon-launch-gui ${pkgs.kdePackages.plasma-workspace}/libexec/plasma-dbus-run-session-if-needed startplasma-wayland";
  };
}
