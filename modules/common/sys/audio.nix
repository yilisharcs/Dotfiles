{ lib, ... }: let
    inherit (lib) disabled enabled;
in {
    services.pulseaudio = disabled;
    security.rtkit = enabled;
    services.pipewire = enabled {
        alsa = enabled {
            support32Bit = true;
        };
        pulse = enabled;
        # If you want to use JACK applications, uncomment this
        #jack = enabled;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session = enabled;
    };
}
