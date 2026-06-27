{
  config,
  pkgs,
  ...
}: {
  age.secrets.forgejo = let
    owner = "yilisharcs";
  in {
    file = ./auth-json.age;
    inherit owner;
    mode = "0400";
    path = "${config.users.users.${owner}.home}/.local/share/forgejo-cli/keys.json";
  };

  home-manager.sharedModules = [
    {
      # CLI application for interacting with Forgejo
      home.packages = [pkgs.forgejo-cli];

      # fj auth login
      home.sessionVariables = {
        FJ_FALLBACK_HOST = "https://codeberg.org";
      };
    }
  ];
}
