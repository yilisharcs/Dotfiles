{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe;

  # NOTE: some `gh auth` subcommands don't play nice with GH_TOKEN being set.
  #       "auth status" and "auth token" will necessarily be out of sync if the
  #       token is changed after a rebuild.
  gh-wrapped = pkgs.writeShellScriptBin "gh" ''
    case "$1 $2" in
      "auth login" | "auth logout" | "auth switch" | "auth refresh") ;;
      *) export GH_TOKEN=$(< ${config.age.secrets.github-cli.path})  ;;
    esac
    exec ${getExe pkgs.gh} "$@"
  '';
in {
  age.secrets.github-cli = {
    file = ./auth-token.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    {
      # GitHub CLI tool
      programs.gh = enabled {
        package = gh-wrapped;
        # extensions = [];
        hosts."github.com" = {
          user = "yilisharcs";
          git_protocol = "ssh";
        };
        settings = {
          git_protocol = "ssh";
          # editor = "";
          prompt = "enabled";
          pager = "${getExe pkgs.less}";
          # aliases = {
          #         co = "pr checkout";
          # };
        };
      };
    }
  ];
}
