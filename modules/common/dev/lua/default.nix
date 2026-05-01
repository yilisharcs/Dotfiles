{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            # no ~pkgs.lua5_1~ here...
            pkgs.lua-language-server
            pkgs.stylua # opinionated Lua code formatter
        ];

        ## TODO: review necessity of this
        # home.sessionVariables = {
        #     LUA_PATH  = ";./src/?.lua;./src/?/init.lua;;";
        #     LUA_CPATH = ";./lib/?.so;;";
        # };
    }];
}
