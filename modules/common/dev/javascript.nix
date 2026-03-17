{ pkgs, ... }: {
    home-manager.sharedModules = [{
        # node.js version manager
        home.packages = [ pkgs.fnm ];

        home.sessionPath = [
            "$HOME/.local/share/fnm/aliases/default/bin"
        ];
    }];
}
