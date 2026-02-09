{ pkgs, ... }:{
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.hunspell               # Spell checker
            pkgs.hunspellDicts.pt_BR    # Brazilian Portuguese dictionary
        ];
    }];
}
