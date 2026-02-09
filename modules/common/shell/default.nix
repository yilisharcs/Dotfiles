{
    home-manager.sharedModules = [{
        home.shellAliases = {
            ":q" = "exit";
            visudo = "sudo visudo";
            nsp  = "nix search nixpkgs";
        };

        home.shell.enableShellIntegration = true;
    }];
}
