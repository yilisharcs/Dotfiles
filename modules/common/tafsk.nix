{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.tafsk              # Organize tasks like a file system
        ];

        home.sessionVariables = {
            TAFSK_STORE_DIR = "$HOME/Shared/notebook/tasks";
        };
    }];
}
