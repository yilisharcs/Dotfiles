{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe;

  concord-wrapped-main = pkgs.writeShellScriptBin "concord" ''
    export CONCORD_TOKEN=$(< ${config.age.secrets.discord-main.path})
    exec ${getExe pkgs.concord-tui}
  '';

  concord-wrapped-work = pkgs.writeShellScriptBin "woncord" ''
    export CONCORD_TOKEN=$(< ${config.age.secrets.discord-work.path})
    exec ${getExe pkgs.concord-tui}
  '';
in {
  age.secrets.discord-main = {
    file = ./auth-token-main.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  age.secrets.discord-work = {
    file = ./auth-token-work.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    {
      # Feature-rich TUI client for Discord
      home.packages = [concord-wrapped-work];
      programs.concord = enabled {
        package = concord-wrapped-main;
        keymapSettings.composer = {
          OpenEditor = "<C-o>";
          DeletePreviousChar = {keys = ["<C-h>" "backspace"];};
          MoveCursorLeft = {keys = ["<C-b>" "left"];};
          MoveCursorRight = {keys = ["<C-f>" "right"];};
          MoveCursorHome = "<C-a>";
          MoveCursorEnd = "<C-e>";
          InsertNewline = "<C-j>";
        };
        themeSettings = {
          highlight.CategoryHeading = {
            foreground = lib.colors.moyin.lightBlue;
          };
          highlight.FolderFallback = {
            foreground = lib.colors.moyin.cyan;
          };
        };
      };
    }
  ];
}
