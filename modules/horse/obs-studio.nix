{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    # FOSS program for video recording and live streaming
    programs.obs-studio = enabled {
        plugins = [
            pkgs.obs-studio-plugins.obs-pipewire-audio-capture
            pkgs.obs-studio-plugins.obs-vaapi
            pkgs.obs-studio-plugins.obs-vkcapture
        ];
    };
}
