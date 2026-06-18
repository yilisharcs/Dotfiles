{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.sonic3air
      ];
    }
  ];
}
