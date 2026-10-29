{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # Free and open source painting application
      home.packages = [pkgs.krita];

      programs.yazi.settings.opener = {
        krita = [
          {
            desc = "Open with Krita";
            run = "krita %s";
            orphan = true;
          }
        ];
      };

      yaziPrependOpenRules.image.use = ["krita"];
    }
  ];
}
