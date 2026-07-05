{
  config,
  inputs,
  pkgs,
  ...
}: let
  concord = inputs.concord.packages.${pkgs.system}.default.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patch/0001-feat-support-CONCORD_TOKEN-env-var-in-Auto-credentia.patch
      ];
  });

  concord-wrapped = pkgs.writeShellScriptBin "concord" ''
    export CONCORD_TOKEN=$(< ${config.age.secrets.discord.path})
    exec ${concord}/bin/concord
  '';
in {
  age.secrets.discord = {
    file = ./auth-token.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    {
      # Feature-rich TUI client for Discord
      home.packages = [concord-wrapped];

      xdg.configFile."concord/keymap.toml".source = (pkgs.formats.toml {}).generate "keymap.toml" {
        keymap.composer = {
          OpenEditor = "<C-o>";
          DeletePreviousChar = "<C-h>";
          MoveCursorLeft = "<C-b>";
          MoveCursorRight = "<C-f>";
          MoveCursorHome = "<C-a>";
          MoveCursorEnd = "<C-e>";
          InsertNewline = "<C-j>";
        };
      };
    }
  ];
}
