{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # Disk space analyzer
      home.packages = [pkgs.gdu];

      xdg.configFile."gdu/gdu.yaml".source = ./gdu.yaml;
    }
  ];
}
