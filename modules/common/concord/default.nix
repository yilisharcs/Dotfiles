{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe;

  concord = inputs.concord.packages.${pkgs.system}.default.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patch/0001-chore-remove-version-check.patch
      ];
  });

  concord-wrapped-main = pkgs.writeShellScriptBin "concord" ''
    export CONCORD_TOKEN=$(< ${config.age.secrets.discord-main.path})
    exec ${getExe concord}
  '';

  concord-wrapped-work = pkgs.writeShellScriptBin "woncord" ''
    export CONCORD_TOKEN=$(< ${config.age.secrets.discord-work.path})
    exec ${getExe concord}
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
      home.packages = [
        concord-wrapped-main
        concord-wrapped-work
      ];

      xdg.configFile."concord/keymap.toml".source = (pkgs.formats.toml {}).generate "keymap.toml" {
        keymap.composer = {
          OpenEditor = "<C-o>";
          DeletePreviousChar = {keys = ["<C-h>" "backspace"];};
          MoveCursorLeft = {keys = ["<C-b>" "left"];};
          MoveCursorRight = {keys = ["<C-f>" "right"];};
          MoveCursorHome = "<C-a>";
          MoveCursorEnd = "<C-e>";
          InsertNewline = "<C-j>";
        };
      };
    }
  ];
}
