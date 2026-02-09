{ lib, ... }: let
    inherit (lib) disabled enabled;
in {
    home-manager.sharedModules = [{
        programs = {
            # Harder, better, faster, stronger grep.
            # bin = `rg`
            ripgrep = enabled {
                arguments = [
                    # Search hidden files / directories (e.g. dotfiles) by default
                    "--hidden"
                    # Enable smart case
                    "--smart-case"
                    # Exclude files/folders with glob patterns
                    "--glob=!.bak*"
                    "--glob=!.cache/*"
                    "--glob=!.git/*"
                    "--glob=!.npm/*"
                    "--glob=!Trash/*"
                ];
            };

            # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more.
            # bin = `rga`
            ripgrep-all = disabled {};
        };
    }];
}
