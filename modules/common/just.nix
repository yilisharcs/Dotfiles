{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # Handy way to save and run project-specific commands
      home.packages = [pkgs.just];

      home.sessionVariables = {
        JUST_COMMAND_COLOR = "yellow";
      };
    }
  ];
}
