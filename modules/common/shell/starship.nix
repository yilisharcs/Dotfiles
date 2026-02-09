{ lib, pkgs, ... }: let
    inherit (lib) enabled concatStrings mergeAttrsList recursiveUpdate;

    getPreset = name: (with builtins; removeAttrs (fromTOML (readFile
        "${pkgs.starship}/share/starship/presets/${name}.toml")) [''"$schema"'']);
in {
    home-manager.sharedModules = [{
        home.sessionVariables = {
            STARSHIP_LOG = "error";
        };

        # Multishell prompt engine
        programs.starship = enabled {
            enableBashIntegration = false;
            settings = recursiveUpdate (mergeAttrsList [(getPreset "nerd-font-symbols")]) {
                add_newline = false;
                command_timeout = 300;
                format = concatStrings [
                    "$all"
                    "$shell"
                    "$time"
                    "$character"
                ];
                character = {
                    success_symbol = "[\\$](bold green)";
                    error_symbol   = "[\\$](bold red)";
                };
                git_status = {
                    format = "([\\[$all_status$ahead_behind\\]]($style) )";
                    deleted = "[✘](italic red)";
                };
                package = {
                    format = "(is [󰏗 $version]($style) )";
                    symbol = "󰏗 ";
                };
                time = {
                    disabled = false;
                    format = "\\[[$time]($style)\\]";
                    style = "bold yellow";
                    time_format = "%H:%M";
                    use_12hr = false;
                };
                fill.symbol = " ";
            };
        };
    }];
}
