{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            # NOTE: no `pkgs.lua5_1` here...
            pkgs.lua-language-server
            pkgs.stylua                 # opinionated Lua code formatter
        ];
    }];
}
