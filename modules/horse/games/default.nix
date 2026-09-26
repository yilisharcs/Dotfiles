{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.mega-man-x8-16-bit
      ];
    }
  ];
}
