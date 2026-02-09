inputs: self: super: let
    inherit (self) attrValues filter getAttrFromPath hasAttrByPath collectNix;
    inherit (inputs) home-manager;

    commonModules = collectNix ../modules/common;
    horseModules = collectNix ../modules/horse;

    collectInputs = let
        inputs' = attrValues inputs;
    in path: inputs'
    |> filter (hasAttrByPath path)
    |> map (getAttrFromPath path);

    inputHomeModules   = collectInputs [ "homeModules"   "default" ];
    inputModulesLinux  = collectInputs [ "nixosModules"  "default" ];

    inputOverlays = collectInputs [ "overlays" "default" ];
    overlayModule = { nixpkgs.overlays = inputOverlays; };

    specialArgs = inputs // {
        inherit inputs;
        lib  = self;
    };
in {
    inherit horseModules;

    nixosSystem' = { isHorse ? false, module }: super.nixosSystem {
        inherit specialArgs;

        modules = [
            module
            overlayModule
            home-manager.nixosModules.home-manager
            {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = inputHomeModules ++ [
                    inputs.plasma-manager.homeModules.plasma-manager
                ];
            }
        ] ++ commonModules
            ++ (self.optionals isHorse horseModules)
            ++ inputModulesLinux;
    };
}
