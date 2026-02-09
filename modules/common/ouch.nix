{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            pkgs.ouch   # File compression and decompression utility

            pkgs.gnutar # GNU implementation of the `tar' archiver
            pkgs.gzip   # Standard GNU compression utilities
            pkgs.p7zip  # 7-Zip is a file archiver with a high compression ratio
            pkgs.unrar  # Unarchiver for .rar files
            pkgs.unzip  # Extraction utility for archives compressed in .zip format
            pkgs.xz     # Library and command line tools for XZ and LZMA compressed files
            pkgs.zip    # Compressor/archiver for creating and modifying zipfiles
            pkgs.zstd   # Zstandard real-time compression algorithm
        ];

        programs.yazi = {
            plugins.ouch = pkgs.yaziPlugins.ouch;
            settings.plugin.prepend_previewers = [
                { mime = "application/{gzip,x-xz,zip,zstd}";  run = "ouch"; }
            ];
            keymap.mgr.prepend_keymap = [
                { on = [ "e" "e" ]; run = "shell          'ouch d \"$@\"'";                       desc = "Extract archive"; }
                { on = [ "e" "g" ]; run = "shell --orphan 'ouch c --slow \"$@\" \"$0\".tar.gz'";  desc = "Compress as .tar.gz"; }
                { on = [ "e" "t" ]; run = "shell --orphan 'ouch c --slow \"$@\" \"$0\".tar.zst'"; desc = "Compress as .tar.zst"; }
                { on = [ "e" "x" ]; run = "shell --orphan 'ouch c --slow \"$@\" \"$0\".tar.xz'";  desc = "Compress as .tar.xz"; }
                { on = [ "e" "z" ]; run = "shell --orphan 'ouch c --slow \"$@\" \"$0\".zip'";     desc = "Compress as .zip"; }
            ];
        };
    }];
}
