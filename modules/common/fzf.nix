{ lib, pkgs, ... }: let
    inherit (lib) concatStrings enabled getExe;
in {
    home-manager.sharedModules = [{
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
            historyWidgetOptions = [
                "--preview-window hidden"
                "--bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
                "--header 'Press CTRL-Y to copy command into clipboard'"
            ];
        };
    }];
}
