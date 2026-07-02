{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled concatStrings mergeAttrsList recursiveUpdate;

  getPreset = name: (with builtins;
    "${pkgs.starship}/share/starship/presets/${name}.toml"
    |> readFile
    |> fromTOML
    |> (s: removeAttrs s [''"$schema"'']));
in {
  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        STARSHIP_LOG = "error";
      };

      # Multishell prompt engine
      programs.starship = enabled {
        enableNushellIntegration = false;
        settings =
          [(getPreset "nerd-font-symbols")]
          |> mergeAttrsList
          |> (base:
            recursiveUpdate base {
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
                error_symbol = "[\\$](bold red)";
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
            });
      };
    }
  ];
}
