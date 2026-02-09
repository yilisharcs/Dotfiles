{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.typst # Markup-based typesetting system
            pkgs.tinymist # Typst language server and more
            # pkgs.websocat # (DEPS: typst-preview.nvim)
        ];
    }];
}
