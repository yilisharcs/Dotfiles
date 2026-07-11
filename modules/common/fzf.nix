{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) concatStrings enabled getExe;

  clip-sel = pkgs.writeShellScriptBin "clip-sel" ''
    if [ -n "$TMUX" ]; then
      printf '%s' "$*" | tmux set-buffer
    else
      printf '%s' "$*" | wl-copy
    fi
  '';
in {
  home-manager.sharedModules = [
    {
      # Command-line fuzzy finder written in Go
      programs.fzf = enabled {
        defaultCommand = concatStrings [
          "${getExe pkgs.fd}"
          " --color=never"
          " --ignore-case"
          " --strip-cwd-prefix"
          " --hidden"
          " --follow"
          " --type f"
          " --type l"
          " --exclude={.git,.jj,.cache,.npm}"
        ];
        defaultOptions = [
          "--preview '${getExe pkgs.bat} {} --color=always --wrap=never --style=plain --line-range=:500'"
          "--layout=reverse"
          "--multi"
          "--bind='ctrl-j:preview-page-down'"
          "--bind='ctrl-k:preview-page-up'"
          "--bind='backward-eof:abort'"
          "--bind='F4:toggle-preview'"
        ];
        historyWidget.options = [
          "--preview-window hidden"
          "--bind='ctrl-y:execute-silent(${getExe clip-sel} {2..})+abort'"
          "--header 'Press CTRL-Y to copy command into clipboard'"
        ];
      };
    }
  ];
}
