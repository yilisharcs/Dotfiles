{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;

  # NOTE: this is only necessary because kmscon renders the listed characters
  #       incorrectly. i will try to fix that in the source code proper soon.
  patchScript =
    pkgs.writers.writePython3Bin "patch-blocks" {
      libraries = [pkgs.python3Packages.fonttools];
    }
    /*
    python
    */
    ''
      # fix 1-pixel gap at top of block/box-drawing chars.
      # FreeType rounds glyph bitmaps down; extending topmost
      # points by 50 font units (~1px at 16-22pt) fixes it.
      from fontTools.ttLib import TTFont
      import sys

      EXTEND = 50  # font units to extend (~1px at 22pt, 1000 upem)

      PATCH_CHARS = {
          # vertical lines │┃
          0x2502, 0x2503,
          # corners └┕┖┗┘┙┚┛├┝┞┠
          0x2514, 0x2515, 0x2516, 0x2517,
          0x2518, 0x2519, 0x251A, 0x251B,
          # T-junctions ├┝┞┠ ┤┥┦┧┪┤
          0x251C, 0x251D, 0x251E, 0x2520,
          0x2521, 0x2524, 0x2525, 0x2526,
          0x2527, 0x2529, 0x252A,
          # bottom junctions ┴┵┶┷
          0x2534, 0x2535, 0x2536, 0x2537,
          # crosses ┼┽┾┿
          0x253C, 0x253D, 0x253E, 0x253F,
          # double/thick crosses ╀╞╟
          0x2540, 0x2541, 0x2542, 0x2543,
          0x2544, 0x2545, 0x2546, 0x2547,
          0x2549, 0x254A, 0x254B,
          # double vertical ║
          0x2551,
          # double corners ╘╙╚╛╜╝
          0x2558, 0x2559, 0x255A, 0x255B,
          0x255C, 0x255D,
          # double T-junctions ╞╟╠╡╢╣
          0x255E, 0x255F, 0x2560, 0x2561,
          0x2562, 0x2563,
          # double bottom ╧╨
          0x2567, 0x2568, 0x2569, 0x256A,
          0x256B, 0x256C,
          # rounded corners ╯╰
          0x256F, 0x2570,
          # diagonals ╱╲╳
          0x2571, 0x2572, 0x2573,
          # vertical fragments ╵╹╽╿
          0x2575, 0x2579, 0x257D, 0x257F,
          # upper half block ▀
          0x2580,
          # full/left/right blocks █▉▊▋▌▍▎▏
          0x2588, 0x2589, 0x258A, 0x258B,
          0x258C, 0x258D, 0x258E, 0x258F,
          # right block
          0x2590,
          # shade characters ░▒▓
          # FIXME: these should be replaced entirely.
          #        the extension logic distorts them!
          0x2591, 0x2592, 0x2593,
          # thin blocks ▔▕
          0x2594, 0x2595,
          # quadrants ▘▙▚▛▜▝▞▟
          0x2598, 0x2599, 0x259A, 0x259B,
          0x259C, 0x259D, 0x259E, 0x259F,
      }

      font = TTFont(sys.argv[1])
      glyf = font["glyf"]
      cmap = font.getBestCmap()

      for cpt in PATCH_CHARS:
          name = cmap[cpt]
          glyph = glyf[name]

          # for composite glyphs, shift each component's y-offset up
          if glyph.numberOfContours == -1:
              for comp in glyph.components:
                  comp.y += EXTEND

          # for simple glyphs, extend points at yMax upward
          elif glyph.numberOfContours >= 1:
              coords = glyph.coordinates
              y_max = max(c[1] for c in coords)
              for i, (x, y) in enumerate(coords):
                  if y == y_max:
                      coords[i] = (x, y + EXTEND)
              glyph.coordinates = coords
              glyph.yMax += EXTEND

      font.save(sys.argv[2])
    '';
in {
  fonts.packages = [
    pkgs.corefonts # Microsoft's TrueType fonts for the Web
    pkgs.nerd-fonts.iosevka # Nerd Fonts: Narrow and horizontally tight characters, slashed zero
    (pkgs.nerd-fonts.iosevka-term-slab.overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          for ttf in $out/share/fonts/truetype/NerdFonts/IosevkaTermSlab/*.ttf; do
            ${patchScript}/bin/patch-blocks "$ttf" "$ttf"
          done
        '';
    })) # Nice as Iosevka but patched and with slab serifs
    pkgs.noto-fonts-cjk-sans # Beautiful and free fonts for Chinese-Japanese-Korean languages
    pkgs.noto-fonts-color-emoji # Color emoji font
  ];

  fonts.fontconfig = enabled {
    antialias = true;
    cache32Bit = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
      sansSerif = ["Iosevka Nerd Font" "Noto Color Emoji"];
      serif = ["IosevkaTermSlab Nerd Font" "Noto Color Emoji"];
    };
  };
}
