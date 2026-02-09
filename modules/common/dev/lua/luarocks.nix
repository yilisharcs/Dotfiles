{
    home-manager.sharedModules = [({ config, ... }: {
        home.file.".config/luarocks/config-5.1.lua".text = ''
            local_by_default = true
            local_cache = "${config.home.homeDirectory}/.cache/luarocks"
        '';
    })];
}
