{lib, ...}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    ({options, ...}: {
      programs.bash = enabled {
        initExtra =
          /*
          bash
          */
          ''
            PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND;}history -a"
            HISTTIMEFORMAT="%F %T "

            bind    '"\C-o": edit-and-execute-command'
          '';
        historyControl = ["ignoreboth"];
        historyIgnore = [
          "?(n)vi?(m)*"
          "cd"
          "exit"
          "ls"
          "pwd"
          "[bf]g"
        ];
        shellAliases = {
          ".." = "cd ..";
          cp = "cp -iv";
          rm = "rm -I";
        };
        shellOptions =
          options.programs.bash.shellOptions.default
          ++ [
            "checkwinsize"
          ];
      };
    })
  ];
}
