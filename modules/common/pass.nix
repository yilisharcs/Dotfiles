{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Stores, retrieves, generates, and synchronizes passwords securely
        programs.password-store = enabled {
            ## TODO: configure this properly
            # settings = {};
        };
    }];
}
