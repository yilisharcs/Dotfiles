{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe getExe';

  man-orig = getExe' pkgs.man-db "man";
  man-wrapper =
    (pkgs.writeShellScriptBin "man" ''
      if [ -t 1 ]; then
        for arg in "$@"; do
            case "$arg" in -*) exec ${man-orig} "$@";; esac
        done
        exec ${getExe pkgs.neovim-unwrapped} -c "Man $*" -c "only"
      else
        exec ${man-orig} "$@"
      fi
    '').overrideAttrs (old: {
      meta = (old.meta or {}) // {priority = 4;};
    });
in {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.universal-ctags # Multilanguage implementation of ctags
        man-wrapper
      ];

      # for built-from-repo installations
      home.sessionPath = ["$HOME/opt/neovim/bin"];

      # Terminal text editor
      programs.neovim = enabled {
        sideloadInitLua = true; # Don't overwrite $XDG_CONFIG_HOME/nvim/init.lua stow symlink
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withPython3 = false;
        withRuby = false;
        extraPackages = let
          treesitter-plugin = [
            pkgs.tree-sitter
            pkgs.gcc # NOTE: Needed to compile parsers
          ];
        in
          [
            pkgs.curl # Command-line tool for transferring files with URL syntax
            pkgs.jq # Lightweight JSON processor
          ]
          ++ treesitter-plugin;
      };
    }
  ];

  environment.sessionVariables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };
}
