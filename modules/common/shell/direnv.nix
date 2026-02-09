{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # Shell extension for (un)loading environment variables based on the current directory.
        programs.direnv = enabled {
            nix-direnv = enabled;
            config.global = {
                load_dotenv = true;
                strict_env = true;
                log_filter = "^loading";
                warn_timeout = "30m";
            };
        };
    }];
}
