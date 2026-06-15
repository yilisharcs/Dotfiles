{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.forgejo-cli # CLI application for interacting with Forgejo
      ];

      # fj auth login
      home.sessionVariables = {
        FJ_FALLBACK_HOST = "https://codeberg.org";
      };
    }
  ];
}
