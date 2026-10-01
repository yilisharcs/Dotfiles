{
  config,
  lib,
  pkgs,
  ...
}: let
  forgejoKeysPath = config.age.secrets.forgejo.path;
in {
  age.secrets.forgejo = {
    file = ./auth-json.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    ({config, ...}: {
      # CLI application for interacting with Forgejo
      home.packages = [pkgs.forgejo-cli];

      # fj auth login
      home.sessionVariables = {
        FJ_FALLBACK_HOST = "https://codeberg.org";
      };

      home.file.".local/share/forgejo-cli/keys.json".source =
        config.lib.file.mkOutOfStoreSymlink forgejoKeysPath;
    })
  ];
}
