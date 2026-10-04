{pkgs, ...}: {
  home-manager.sharedModules = [
    # {
    #   # Vector graphics editor
    #   home.packages = [pkgs.inkscape];
    #
    #   programs.yazi.settings.opener = {
    #     inkscape = [
    #       {
    #         desc = "Open with Inkscape";
    #         run = "inkscape %s";
    #         orphan = true;
    #       }
    #     ];
    #   };
    #
    #   yaziPrependOpenRules.image.use = ["inkscape"];
    # }
  ];
}
