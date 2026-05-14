{ lib, pkgs, ... }: let
    inherit (lib) getExe;

    tokeicon = pkgs.writeScriptBin "tokeicon" /* nu */ ''
        #!${getExe pkgs.nushell}

        def main [ --exclude (-e): string = "" ] {
            let flag = (if $exclude != "" { ["--exclude" $exclude] } else { [] })

            tokei --hidden --compact --sort code ...$flag
            | lines
            | where $it !~ "━"
            | str trim
            | split column --regex '\s\s+'
            | rename ...($in | first | values)
            | skip 1
            | drop
            | update Code {|e| $e.Code | into int }
            | do {
                let total = ($in | get Code | math sum)
                $in | insert Percent {|e| ($e.Code * 100 / $total)}
            }
            | where Code > 0
            | select Language Code Percent
        }
    '';
in {
    home-manager.sharedModules = [{
        # LoC counter
        home.packages = [
            pkgs.tokei
            tokeicon
        ];
    }];
}
