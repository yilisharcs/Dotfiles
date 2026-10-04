{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # GNU Image Manipulation Program
      home.packages = [pkgs.gimp];

      programs.yazi.settings.opener = {
        gimp = [
          {
            desc = "Open with GIMP";
            run = "gimp %s";
            orphan = true;
          }
        ];
      };

      yaziPrependOpenRules.image.use = ["gimp"];
    }
  ];
}
