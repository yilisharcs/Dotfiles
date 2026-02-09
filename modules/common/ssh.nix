{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        programs.ssh = enabled {
            enableDefaultConfig = false; # NOTE: will be deprecated soon
            matchBlocks."*".addKeysToAgent = "yes";
        };

        # TODO: make my ssh keys subkeys of the master gpg key
        services.ssh-agent = enabled;
    }];
}
