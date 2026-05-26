{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.luajit
        pkgs.lua-language-server
        pkgs.stylua # opinionated Lua code formatter
      ];
    }
  ];
}
