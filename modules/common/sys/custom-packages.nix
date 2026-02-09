{
    # TODO: this should be elsewhere no?
    nixpkgs.overlays = [
        (final: prev: import ../../../pkgs { pkgs = final; lib = prev.lib; })
    ];
}
