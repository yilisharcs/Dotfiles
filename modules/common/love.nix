{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.love              # Lua-based 2D game engine/scripting language
        ];
    }];
}
