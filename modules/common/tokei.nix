{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # LoC counter
      home.packages = [
        pkgs.tokei
      ];
    }
  ];
}
