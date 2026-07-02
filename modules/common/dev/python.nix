{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.python3
      ];
    }
  ];
}
