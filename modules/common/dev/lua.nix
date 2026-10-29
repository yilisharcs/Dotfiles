{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.lua5_5
        pkgs.lua-language-server
        pkgs.stylua # opinionated Lua code formatter
      ];
    }
  ];
}
