{ lib, pkgs, ... }: let
    inherit (lib) enabled;
in {
    console = enabled {
        earlySetup = true;
        font       = "ter-232b";
        packages   = [ pkgs.terminus_font ];
    };

    fonts.packages = [
        pkgs.corefonts                          # Microsoft's TrueType fonts for the Web
        pkgs.nerd-fonts.iosevka                 # Nerd Fonts: Narrow and horizontally tight characters, slashed zero
        pkgs.nerd-fonts.iosevka-term-slab       # Nice as Iosevka but with slab serifs
        pkgs.noto-fonts-cjk-sans                # Beautiful and free fonts for Chinese-Japanese-Korean languages
        pkgs.noto-fonts-color-emoji             # Color emoji font
    ];

    fonts.fontconfig = enabled {
        antialias = true;
        cache32Bit = true;
        defaultFonts = {
            emoji     = [ "Noto Color Emoji" ];
            sansSerif = [ "Iosevka Nerd Font" ];
            serif     = [ "IosevkaTermSlab Nerd Font" ];
        };
    };
}
