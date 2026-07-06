{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled mergeAttrsList recursiveUpdate;

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
        settings =
          [(getPreset "nerd-font-symbols")]
          |> mergeAttrsList
          |> (base:
            recursiveUpdate base {
              add_newline = false;
              command_timeout = 300;
              character = {
                success_symbol = "[λ](bold bright-blue)";
                error_symbol = "[λ](bold red)";
              };
              directory.style = "bold blue";
              git_branch.style = "bold white";
              git_commit.disabled = true;
              git_status.style = "bold white";
              package.style = "bold white";
              cmd_duration.style = "bold cyan";
              shell.disabled = false;
            });
      };
    }
  ];
}
