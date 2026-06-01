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
          "*" = {
            AddKeysToAgent = "yes";
            Compression = false;
            ControlMaster = "no";
            ControlPersist = "no";
            ForwardAgent = false;
            HashKnownHosts = true;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            # ServerAliveInterval = 0;
            # ServerAliveCountMax = 3;
            # ControlPath = "~/.ssh/master-%r@%n:%p";
          };
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
