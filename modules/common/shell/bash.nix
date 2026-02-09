{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;
in {
    home-manager.sharedModules = [({ options, ... }: {
        programs.bash = enabled {
            initExtra = ''
                # Use nushell in place of bash, unless calling bash from nushell.
                # `nvim -c term` needs an exception to ensure nushell is called.
                # https://wiki.gentoo.org/wiki/Nushell#Caveats
                if [ -x "${getExe pkgs.nushell}" ] &&
                        { [ "$SHLVL" -eq 1 ] || { [ "$SHLVL" -eq 2 ] && [ -n "$NVIM" ]; }; }; then
                                export SHELL="${getExe pkgs.nushell}"
                                exec "${getExe pkgs.nushell}"
                fi

                PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
                PROMPT_COMMAND='history -a'
                HISTTIMEFORMAT="%F %T "

                bind    '"\C-o": edit-and-execute-command'
            '';
            historyControl = [ "ignoreboth" ];
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
            shellOptions = options.programs.bash.shellOptions.default ++ [
                "checkwinsize"
            ];
        };
    })];
}
