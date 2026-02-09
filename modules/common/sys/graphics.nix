{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    # Auxiliary package. Provides... a lot of stuff. I only care about `glxinfo`.
    environment.systemPackages = [ pkgs.mesa-demos ];

    hardware.graphics = enabled {
        enable32Bit = true;
        extraPackages = [ pkgs.intel-vaapi-driver ];
    };
}
