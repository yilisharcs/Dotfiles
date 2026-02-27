{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe getExe';
in {
    # TODO: perhaps dependent keys should be in their own respective files??
    #           gimp     = [{ desc = "Open with GIMP";     run = ''gimp "$@"'';     orphan = true; }];
    #
    #           inkscape = [{ desc = "Open with Inkscape"; run = ''inkscape "$@"''; orphan = true; }];
    #
    #           vlc: play = [
    #               { desc = "Open with VLC";   run = ''vlc "$@"'';            orphan = true; for = "unix"; }
    #               { desc = "Show media info"; run = ''mediainfo "$1" | bat''; block = true; for = "unix"; }
    #           ];
    #
    home-manager.sharedModules = [{
        # Blazing fast terminal file manager written in Rust, based on async I/O
        programs.yazi = enabled {
            # HACK: https://github.com/sxyazi/yazi/issues/3671
            package = pkgs.yazi.override { chafa = null; };
            extraPackages = [
                pkgs.exiftool             # Read/write metadata in files
                pkgs.file
            ];
            shellWrapperName = "yf";
            plugins = {
                chmod = pkgs.yaziPlugins.chmod;
                smart-enter = pkgs.yaziPlugins.smart-enter;
            };
            # https://github.com/sxyazi/yazi/tree/main/yazi-config/preset
            settings = {
                mgr = {
                    sort_by = "natural";
                    sort_sensitive = false;
                    sort_dir_first = true;
                    sort_translit = true;
                    linemode = "mtime";
                    show_hidden = true;
                    show_symlink = true;
                    scrolloff = 2;
                };
                preview.wrap = "yes";
                opener = {
                    # play = [
                    #     { desc = "Open with VLC";   run = ''vlc "$@"'';            orphan = true; for = "unix"; }
                    #     { desc = "Show media info"; run = ''mediainfo "$1" | bat''; block = true; for = "unix"; }
                    # ];
                    # gimp     = [{ desc = "Open with GIMP";     run = ''gimp "$@"'';     orphan = true; }];
                    # inkscape = [{ desc = "Open with Inkscape"; run = ''inkscape "$@"''; orphan = true; }];
                    xbin     = [{ desc = "Execute binary";     run = ''"$@"'';          orphan = true; }];
                    # calibre  = [{ desc = "Read with Calibre";  run = ''ebook-viewer "$@"'';  orphan = true; }];
                    # wine     = [{ desc = "Execute with Wine";  run = ''firejail wine "$@"''; orphan = true; }];
                };
                open = {
                    prepend_rules = [
                        { mime = "text/*";                            use = [ "edit" "reveal" ]; }
                        { mime = "inode/x-empty";                     use = "edit"; }
                        { name = "*.html";                            use = [ "open" "edit" ]; }
                        #         { mime = "image/*";                           use = [ "open" "gimp" "inkscape" "reveal" ]; }
                        #opt2     { mime = "image/*",                           use = [ "open", "gimp", "reveal" ] },
                        #         { mime = "application/{epub+zip, zip}",       use = "calibre" },
                        { mime = "application/{gzip,x-xz,zip,zstd}";  use = [ "edit" "reveal" ]; }
                        { mime = "application/{pie-executable,executable}";         use = "xbin"; }
                        # { mime = "application/{microsoft.portable-executable,msi}"; use = "wine"; }
                    ];
                };
                confirm = {
                    trash = true;
                    delete = true;
                    overwrite = true;
                };
            };
            keymap.mgr.prepend_keymap = [
                { on = ":"; run = "shell '${getExe pkgs.nushell}' --block"; desc = "Launch a shell"; }

                # Smart enter
                { on = "l"; run = "plugin smart-enter"; desc = "Enter the child directory; or open the file"; }

                # chmod
                { on = "C"; run = "plugin chmod"; desc = "Change file permissions"; }

                # Backup
                { on = "b"; run = "shell 'for f in \"$@\"; do cp -r \"$f\" \"$f.bak.$(date +%%s)\"; done'"; desc = "Backup current file"; }

                # Pager
                { on = "i"; run = "shell '${getExe pkgs.bat} \"$0\" --pager=\"${getExe pkgs.less} -+F\"' --block"; }

                # Restore trashed files
                {
                    on = "u";
                    run = ''shell 'file=$(${getExe' pkgs.trash-cli "trash-list"} | grep "$(pwd)"''
                        + '' | ${getExe pkgs.fzf} --preview-window hidden | cut -b21-) && [ -n "$file" ] && yes 0''
                        + '' | ${getExe' pkgs.trash-cli "trash-restore"} "$file"' --block'';
                    desc = "Restore trashed file";
                }

                # Plugins
                { on = "z"; run = "plugin zoxide"; desc = "Jump to a directory via zoxide"; }
                { on = "Z"; run = "plugin fzf";    desc = "Jump to a file/directory via fzf"; }

                # Hardlink
                { on = "<C-A-->"; run = "hardlink";    desc = "Hardlink yanked files"; }

                # Goto
                { on = [ "g" "/" ]; run = "cd /";                                          desc = "Go to root"; }
                { on = [ "g" "a" ]; run = "cd ~/Projects/github.com/yilisharcs/";          desc = "Go to local github.com/yilisharcs"; }
                { on = [ "g" "A" ]; run = "cd ~/Projects/github.com/sonicretro/skdisasm/"; desc = "Go to S3K Disassembly"; }
                { on = [ "g" "b" ]; run = "cd ~/Shared/notebook";                          desc = "Go to notebook"; }
                { on = [ "g" "B" ]; run = "cd ~/Shared/notebook/vault";                    desc = "Go to vault"; }
                { on = [ "g" "c" ]; run = "cd ~/.config";                                  desc = "Go ~/.config"; }
                { on = [ "g" "d" ]; run = "cd ~/Downloads";                                desc = "Go ~/Downloads"; }
                { on = [ "g" "e" ]; run = "cd ~/Documents";                                desc = "Go ~/Documents"; }
                { on = [ "g" "E" ]; run = "cd ~/Documents/Archivum";                       desc = "Go to the creative archive"; }
                { on = [ "g" "f" ]; run = "follow";                                        desc = "Follow hovered symlink"; }
                { on = [ "g" "i" ]; run = "cd ~/Pictures";                                 desc = "Go ~/Pictures"; }
                # { on = [ "g" "k" ]; run = "cd ~/Nixcfg";                                   desc = "Go ~/Nixcfg"; }
                { on = [ "g" "l" ]; run = "cd ~/Dotfiles";                                 desc = "Go ~/Dotfiles"; }
                { on = [ "g" "m" ]; run = "cd ~/Music";                                    desc = "Go ~/Music"; }
                { on = [ "g" "n" ]; run = "cd ~/.config/nvim";                             desc = "Go to nvim/init.lua"; }
                { on = [ "g" "o" ]; run = "cd ~/opt";                                      desc = "Go to private /opt"; }
                { on = [ "g" "p" ]; run = "cd ~/Projects";                                 desc = "Go ~/Projects"; }
                # { on = [ "g" "r" ]; run = "cd ~/.cargo/registry/src";                      desc = "Go to cargo registry"; }
                { on = [ "g" "s" ]; run = "cd ~/.local/bin";                               desc = "Go to private /bin"; }
                { on = [ "g" "u" ]; run = "cd ~/Library";                                  desc = "Go ~/Library"; }
                { on = [ "g" "v" ]; run = "cd ~/Videos";                                   desc = "Go ~/Videos"; }
                { on = [ "g" "w" ]; run = "cd ~/.wine/drive_c";                            desc = "Go to Wine C:"; }
                { on = [ "g" "y" ]; run = "cd ~/Games";                                    desc = "Go ~/Games"; }
                { on = [ "g" "x" ]; run = "cd ~/.local/state/nvim";                        desc = "Go to state/nvim"; }
                { on = [ "g" "z" ]; run = "cd ~/.local/share/nvim/lazy";                   desc = "Go to lazydir"; }
            ];
            theme = {
                mgr = {
                    count_copied   = { fg = "black"; bg = "green"; };
                    count_cut      = { fg = "black"; bg = "red"; };
                    count_selected = { fg = "black"; bg = "yellow"; };
                };
                tabs = {
                    active   = { bg = "blue"; fg = "black"; bold = true; };
                    inactive = { fg = "blue"; bg = "black"; };
                };
                mode = {
                    normal_main = { bg = "blue"; fg = "black"; bold = true; };
                    normal_alt  = { fg = "blue"; bg = "black"; };
                    select_main = { bg = "red";  fg = "black"; bold = true; };
                    select_alt  = { fg = "red";  bg = "black"; };
                    unset_main  = { bg = "red";  fg = "black"; bold = true; };
                    unset_alt   = { fg = "red";  bg = "black"; };
                };
                icon = {
                    prepend_dirs = [
                        { name = ".git";      text = ""; fg = "#f54d27"; }
                        { name = ".jj";       text = ""; fg = "#f54d27"; }
                        { name = "Documents"; text = ""; fg = "#85ea2d"; }
                        { name = "Dotfiles";  text = ""; fg = "#85ea2d"; }
                        { name = "Downloads"; text = ""; fg = "#85ea2d"; }
                        { name = "Games";     text = "󰺶"; fg = "#85ea2d"; }
                        { name = "Library";   text = ""; fg = "#85ea2d"; }
                        { name = "Music";     text = ""; fg = "#85ea2d"; }
                        { name = "Pictures";  text = ""; fg = "#85ea2d"; }
                        { name = "Projects";  text = ""; fg = "#85ea2d"; }
                        { name = "Shared";    text = "󱖡"; fg = "#c87bff"; }
                        { name = "Videos";    text = ""; fg = "#85ea2d"; }
                    ];
                    prepend_files = [
                        { name = ".exrc";       text = ""; fg = "#019833"; }
                        { name = ".nvimrc";     text = ""; fg = "#019833"; }
                        { name = "maskfile.md"; text = ""; fg = "#6d8086"; }
                    ];
                    prepend_exts = [
                        { name = "just";      text = ""; fg = "#6d8086"; }
                        { name = "lemon";     text = ""; fg = "#ddd06a"; }
                        { name = "love";      text = "󰋑"; fg = "#ff5faf"; }
                        { name = "msgpack";   text = ""; fg = "#eca517"; }
                        { name = "ron";       text = "󰠮"; fg = "#dea584"; }
                        { name = "xxd";       text = ""; fg = "#019833"; }
                    ];
                    prepend_conds = [
                        { "if" = "link"; text = ""; fg = "#6d8086"; }
                    ];
                };
            };
        };
    }];
}
