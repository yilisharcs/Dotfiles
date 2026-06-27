{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe;

  gh-wrapped = pkgs.writeShellScriptBin "gh" ''
    export GH_TOKEN=$(< ${config.age.secrets.github-cli.path})
    exec ${getExe pkgs.gh} "$@"
  '';

  # gh auth commands don't play nice with GH_TOKEN being set. for days like these,
  # bypass the wrapper to access the keyring directly, to rotate keys or whatever
  gh-auth = pkgs.writeShellScriptBin "gha" ''
    exec ${getExe pkgs.gh} auth "$@"
  '';
in {
  age.secrets.github-cli = {
    file = ./auth-token.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    {
      home.packages = [gh-auth];

      # GitHub CLI tool
      programs.gh = enabled {
        package = gh-wrapped;
        # extensions = [];
        hosts."github.com" = {
          user = "yilisharcs";
          git_protocol = "ssh";
        };
        settings = {
          # What protocol to use when performing git operations.
          # Supported values: ssh, https
          git_protocol = "ssh";
          # What editor gh should run when creating issues, pull requests,
          # etc. If blank, will refer to environment.
          editor = "nvim";
          # When to interactively prompt. This is a global config that cannot
          # be overridden by hostname. Supported values: enabled, disabled
          prompt = "enabled";
          ## A pager program to send command output to, e.g. "less". If blank,
          ## will refer to environment. Set the value to "cat" to disable the pager.
          pager = "${getExe pkgs.less}";
          ## Aliases allow you to create nicknames for gh commands
          # aliases = {
          #         co = "pr checkout";
          # };
          ## The path to a unix socket through which send HTTP connections.
          ## If blank, HTTP traffic will be handled by net/http.DefaultTransport.
          # http_unix_socket = "";
          ## What web browser gh should use when opening URLs. If blank, will
          ## refer to environment.
          # browser = "";
        };
      };
    }
  ];
}
