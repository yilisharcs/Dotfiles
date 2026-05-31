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
        settings = {
          "*".addKeysToAgent = "yes";
          "codeberg.org" = {
            user = "git";
            identityFile = "~/.ssh/id_ed25519_personal";
            identitiesOnly = true;
          };
          "github.com" = {
            user = "git";
            identityFile = "~/.ssh/id_ed25519_personal";
            identitiesOnly = true;
          };
        };
      };

      home.sessionVariables = {
        SSH_ASKPASS = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
        SSH_ASKPASS_REQUIRE = "prefer";
      };

      services.ssh-agent = enabled;
    }
  ];
}
