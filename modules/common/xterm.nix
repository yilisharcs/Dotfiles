{
    imports = [ ./fonts.nix ];

    home-manager.sharedModules = [{
        xresources.properties = {
            "XTerm*background" = "#0a001a";
            "XTerm*foreground" = "#cdd6f4";
            "XTerm*faceName"   = "IosevkaTermSlab Nerd Font";
            "XTerm*faceSize"   = 14;
            "XTerm*maximized"  = true;
        };
    }];
}
