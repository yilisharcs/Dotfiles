{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  # Namespace-based sandboxing tool for Linux
  programs.firejail = enabled;

  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.winetricks # Easy way to work around problems in Wine
        pkgs.wineWow64Packages.stable # Support for both 32-bit and 64-bit Windows applications
      ];

      programs.yazi.settings.opener = {
        wine = [
          {
            desc = "Execute with Wine";
            run = ''firejail wine "$@"'';
            orphan = true;
          }
        ];
      };
      yaziPrependOpenRules.wine = {
        mime = "application/{microsoft.portable-executable,msi}";
        use = ["wine"];
      };
    }
  ];
}
