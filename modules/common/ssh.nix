{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    {
      programs.ssh = enabled {
        enableDefaultConfig = false; # NOTE: will be deprecated soon
        matchBlocks."*".addKeysToAgent = "yes";
      };

      home.sessionVariables = {
        SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
        SSH_ASKPASS_REQUIRE = "prefer";
      };

      services.ssh-agent = enabled;
    }
  ];
}
