{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  nixpkgs.overlays = [
    (final: prev: {
      obs-studio = prev.obs-studio.override {
        # takes up a lot of disk space
        browserSupport = false;
      };
    })
  ];

  # FOSS program for video recording and live streaming
  programs.obs-studio = enabled {
    plugins = [
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      pkgs.obs-studio-plugins.obs-vaapi
      pkgs.obs-studio-plugins.obs-vkcapture
    ];
  };
}
