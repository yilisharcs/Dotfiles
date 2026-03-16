{ lib, pkgs, ... }: let
    inherit (lib) enabled filterAttrs getExe getExe' mapAttrsToList elem filter optional;

    mkKeymap = v: v // { desc = v.desc or v.run; };
in {
    home-manager.sharedModules = [({ config, ... }: {
        yaziPrependOpenRules = {
            text    = { mime = "text/*";                                    use = [ "edit" "reveal" ]; };
            empty   = { mime = "inode/x-empty";                             use = [ "edit" ]; };
            html    = { name = "*.html";                                    use = [ "open" "edit" ]; };
            image   = { mime = "image/*";                                   use = [ "open" "reveal" ]; };
            archive = { mime = "application/{gzip,x-xz,zip,zstd}";          use = [ "edit" "reveal" ]; };
            exec    = { mime = "application/{pie-executable,executable}";   use = [ "xbin" ]; };
        };

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
                    xbin = [{ desc = "Execute binary"; run = ''"$@"''; orphan = true; }];
                };
                open.prepend_rules = mapAttrsToList (k: v:
                    filterAttrs (name: val: val != null && val != []) (v // {
                        use = (optional (elem "open" v.use) "open")
                            ++ (filter (x: x != "open" && x != "reveal") v.use)
                            ++ (optional (elem "reveal" v.use) "reveal");
                })) config.yaziPrependOpenRules;
                confirm = {
                    trash = true;
                    delete = true;
                    overwrite = true;
                };
            };
            keymap.mgr.prepend_keymap = map mkKeymap [
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
                { on = [ "g" "/" ]; run = "cd /"; desc = "Go to root directory"; }
                { on = [ "g" "a" ]; run = "cd ~/Projects/github.com/yilisharcs/"; }
                { on = [ "g" "A" ]; run = "cd ~/Projects/github.com/sonicretro/skdisasm/"; desc = "Go to S3K disassembly"; }
                { on = [ "g" "b" ]; run = "cd ~/Shared/notebook"; }
                { on = [ "g" "B" ]; run = "cd ~/Shared/notebook/vault"; }
                { on = [ "g" "c" ]; run = "cd ~/.config"; }
                { on = [ "g" "d" ]; run = "cd ~/Downloads"; }
                { on = [ "g" "e" ]; run = "cd ~/Documents"; }
                { on = [ "g" "E" ]; run = "cd ~/Documents/Archivum"; }
                { on = [ "g" "f" ]; run = "follow"; desc = "Follow hovered symlink"; }
                { on = [ "g" "i" ]; run = "cd ~/Pictures"; }
                { on = [ "g" "k" ]; run = "cd /nix/store"; }
                { on = [ "g" "l" ]; run = "cd ~/Dotfiles"; }
                { on = [ "g" "m" ]; run = "cd ~/Music"; }
                { on = [ "g" "n" ]; run = "cd ~/.config/nvim"; desc = "Go to nvim init.lua"; }
                { on = [ "g" "o" ]; run = "cd ~/opt"; }
                { on = [ "g" "p" ]; run = "cd ~/Projects"; }
                { on = [ "g" "r" ]; run = "cd ~/.local/share/fnm/aliases/default/lib/node_modules"; desc = "Go to npm registry"; }
                { on = [ "g" "s" ]; run = "cd ~/.local/bin"; }
                { on = [ "g" "u" ]; run = "cd ~/Library"; }
                { on = [ "g" "v" ]; run = "cd ~/Videos"; }
                { on = [ "g" "w" ]; run = "cd ~/.wine/drive_c"; desc = "Go to Wine C: drive"; }
                { on = [ "g" "y" ]; run = "cd ~/Games"; }
                { on = [ "g" "x" ]; run = "cd ~/.local/state/nvim"; }
                { on = [ "g" "z" ]; run = "cd ~/.local/share/nvim/lazy"; desc = "Go to lazydir"; }
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
    })];
}
