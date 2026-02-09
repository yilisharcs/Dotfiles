{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        programs.gpg = enabled {
            mutableKeys = true;
            mutableTrust = true;
            settings.keyid-format = "long";
        };

        # TODO: make my ssh keys subkeys of the master gpg key
        # services.ssh-agent = disabled;
        services.gpg-agent = enabled {
            # enableSshSupport = true;
            defaultCacheTtl = 60480000;
            maxCacheTtl = 60480000;
            pinentry.package = pkgs.pinentry-qt;
        };
    }];
}
