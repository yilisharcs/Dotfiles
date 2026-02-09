{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe;
in {
    home-manager.sharedModules = [({ config, lib, ... }: let
        inherit (lib.hm.dag) entryAfter;
        inherit (lib.hm.nushell) mkNushellInline;
    in {
        home.activation.symlinkNuHist = entryAfter ["writeBoundary"] ''
            run ln -sf "$HOME/.config/nushell/history.txt" "$HOME/.nu_history"
        '';

        home.activation.nuMutableScratchFile = let
            scratch = "${config.home.homeDirectory}/.local/bin/scratch";
        in
            entryAfter ["writeBoundary"] ''
                run mkdir -p ${config.home.homeDirectory}/.local/bin
                run touch ${scratch}
                run chmod 755 ${scratch}
                run echo "#!${getExe pkgs.nushell}

                print $\"(ansi yellow_bold)`scratch` is empty.(ansi reset)\"" > ${scratch}
            '';

        # Nushell is an elegant shell for a more civilized age. It doesn't try to be a tab
        # bit better than bash: it treats pipes as pipelines for structured data, it breaks
        # posix. See <https://www.nushell.sh/book/configuration.html> for configuration
        # options. You can also pretty-print and page through the documentation using:
        #     config nu --doc | nu-highlight | less -R
        programs.nushell = enabled {
            plugins = [
                pkgs.nushellPlugins.gstat
                pkgs.nushellPlugins.query
                # inc
                # semver
            ];
            shellAliases = {
                # wut = "helpless.nu";
                #
                # def h [str: string] { nu -c $"($str) --help" | ${getExe pkgs.less} -FRX }
                fg = "job unfreeze";
            };
            environmentVariables = {
                SUDO_PROMPT = mkNushellInline "$'(ansi red_bold)[sudo](ansi reset) password for %u: '";
            };
            settings = {
                buffer_editor = "nvim";
                display_errors.termination_signal= false;
                history = {
                    file_format = "plaintext";
                    max_size = 10000000;
                    sync_on_enter = true;
                    isolation = false;
                };
                show_banner = false;
                plugin_gc = {
                    default = {
                        enabled = true;
                        stop_after = mkNushellInline "10sec";
                    };
                    plugins = {
                        gstat.stop_after = mkNushellInline "1min";
                        # inc.stop_after = mkNushellInline "0sec";
                    };
                };
                keybindings = [
                {
                    name = "job_to_foreground";
                    modifier = "control";
                    keycode = "char_z";
                    mode = [ "emacs" "vi_insert" "vi_normal" ];
                    event = {
                        send = "executehostcommand";
                        cmd = "job unfreeze";
                    };
                }
                {
                    name = "fuzzy_history";
                    modifier = "control";
                    keycode = "char_r";
                    mode = [ "emacs" "vi_normal" "vi_insert" ];
                    event = {
                        send = "executehostcommand";
                        cmd = ''commandline edit --replace (
                                    history
                                    | reverse
                                    | group-by command
                                    | values
                                    | each { $in.0 }
                                    | each { $"($in.index + 1)     ($in.command)" }
                                    | str join (char -i 0)
                                    | fzf
                                    --read0
                                    --layout reverse
                                    --query (commandline)
                                    --scheme history
                                    --preview-window hidden
                                    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
                                    --header 'Press CTRL-Y to copy command into clipboard'
                                    | decode utf-8
                                    | str trim
                                    | str replace -r "^\\d+\\s{5}" ""
                        )'';
                    };
                }
                ];
            };
        };
    })];
}
