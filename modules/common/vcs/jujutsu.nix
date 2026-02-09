{ lib, pkgs, ... }: let
    inherit (lib) enabled getExe keys;

    jj-help-k = pkgs.writeScriptBin "jjk" ''
        #!${getExe pkgs.nushell}
        $env.config.display_errors.termination_signal = false

        def main [keyword: string] {
            ${getExe pkgs.jujutsu} help -k $keyword
            | ${getExe pkgs.bat} --plain --language markdown
        }
    '';
in {
    home-manager.sharedModules = [{
        programs.difftastic.jujutsu = enabled;

        # git-compatible modern version control system
        home.packages = [ jj-help-k ];
        programs.jujutsu = enabled {
            settings = {
                user = {
                    name  = "yilisharcs";
                    email = "yilisharcs@gmail.com";
                };
                ui = {
                    default-command = [ "ls" ];
                    diff-formatter  = [ "difft" "--color=always" "$left" "$right" ];
                    # pager          = [ (getExe pkgs.bash) "-c" "exec \${PAGER:-${config.environment.variables.PAGER}}" ];
                    # diff-editor    = ":builtin";
                    # conflict-marker-style = "snapshot";
                };
                git = {
                    colocate        = true;
                    fetch           = [ "origin" "upstream" ];
                    push            = "origin";
                    private-commits = "description('wip:*') | description('private:*')";
                };
                signing = {
                    behavior     = "own";
                    backend      = "gpg";
                    key          = keys.gpgKeyId;
                    sign-on-push = true;
                };

                # Shamelessly taken from HSVSphere
                aliases = {
                    a             = [ "abandon" ];
                    c             = [ "commit" ];
                    ci            = [ "commit" "--interactive" ];
                    clone         = [ "git" "clone" ]; # "--colocate"];
                    d             = [ "diff" ];
                    e             = [ "edit" ];
                    fetch         = [ "git" "fetch" ];
                    init          = [ "git" "init" ]; # "--colocate"];
                    l             = [ "log" ];
                    # la          = [ "log" "--revisions" "::" ];
                    ls            = [ "log" "--summary" ];
                    # lsa         = [ "log" "--summary" "--revisions" "::" ];
                    # lp          = [ "log" "--patch" ];
                    # lpa         = [ "log" "--patch" "--revisions" "::" ];
                    r             = [ "rebase" ];
                    push          = [ "git" "push" ];
                    # res         = [ "resolve" ];
                    # resolve-ast = [ "resolve" "--tool" "mergiraf" ];
                    # resa        = [ "resolve-ast" ];
                    s             = [ "squash" ];
                    si            = [ "squash" "--interactive" ];
                    # sh          = [ "show" ];
                    t             = [ "tug" ];
                    # tug         = [ "bookmark" "move" "--from" "closest(@-)" "--to" "closest_pushable(@)" ];
                    u             = [ "undo" ];
                };
                # revset-aliases."closest(to)" = "heads(::to & bookmarks())";
                # revset-aliases."closest_pushable(to)" = "heads(::to & ~description(exact:\"\") & (~empty() | merges()))";
                # revsets.log = "present(@) | present(trunk()) | ancestors(remote_bookmarks().. | @.., 8)";
            };
        };
    }];
}
