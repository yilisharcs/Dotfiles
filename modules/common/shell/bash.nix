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
            export SUDO_PROMPT=$'\e[1;31m[sudo]\e[0m password for %u: '

            PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND;}history -a"
            HISTTIMEFORMAT="%F %T "

            bind    '"\C-o": edit-and-execute-command'
          '';
        historyControl = ["ignoreboth"];
        historyIgnore = [
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
