{ lib, pkgs, ... }: let
    inherit (lib) enabled filter;

    # SIGILL on Ivy Bridge due to standard Bun targeting x86-64-v3; force bun-baseline binary instead
    bun-baseline = pkgs.bun.overrideAttrs (old: {
        src = pkgs.fetchurl {
            url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
            hash = "sha256-QSAajF7nSp3Lsc4loRBPH5KYOLV6hFqnjZg3mwznzeI=";
        };
    });

    opencode-patched = pkgs.opencode.overrideAttrs (old: {
        nativeBuildInputs = [ bun-baseline ]
            ++ (filter (p: (p.pname or "") != "bun") (old.nativeBuildInputs or []));
    });
in {
    home-manager.sharedModules = [{
        # NOTE: don't forget to run `opencode auth login`
        programs.opencode = enabled {
            package = opencode-patched;
            settings = {
                autoupdate = false;
                plugin = [ "opencode-gemini-auth@latest" ];
                permission = {
                    external_directory = {
                        "*" = "ask";
                        "/nix/store/*" = "allow";
                    };
                    bash = {
                        "*" = "ask";

                        "echo *"  = "allow";
                        "file *"  = "allow";
                        "which *" = "allow";

                        "awk *" = "ask";
                        "cp *"  = "ask";
                        "mv *"  = "ask";
                        "rm *"  = "ask";

                        "cat *"       = "allow";
                        "cat << *EOF" = "deny";

                        "df*"       = "allow";
                        "du*"       = "allow";
                        "fd*"       = "allow";
                        "grep *"    = "allow";
                        "head *"    = "allow";
                        "jq *"      = "allow";
                        "ls*"       = "allow";
                        "objdump *" = "allow";
                        "pwd*"      = "allow";
                        "rg *"      = "allow";
                        "sort *"    = "allow";
                        "tail *"    = "allow";
                        "uniq *"    = "allow";
                        "xxd *"     = "allow";

                        "find *"         = "allow";
                        "find *-delete*" = "ask";
                        "find *-exec*"   = "ask";

                        "git *"             = "ask";
                        "git checkout *"    = "deny";
                        "git clean*"        = "deny";
                        "git commit*"       = "deny";
                        "git push*"         = "deny";
                        "git rebase*"       = "deny";
                        "git reset*"        = "deny";
                        "git restore*"      = "deny";
                        "git check-ignore*" = "allow";
                        "git diff*"         = "allow";
                        "git log*"          = "allow";
                        "git ls-files*"     = "allow";
                        "git merge-tree *"  = "allow";
                        "git show*"         = "allow";
                        "git status*"       = "allow";

                        "sed *"            = "allow";
                        "sed *--in-place*" = "deny";
                        "sed *-i*"         = "deny";

                        "gh *"          = "deny";
                        "gh issue view" = "allow";

                        "sudo *" = "deny";
                    };
                    read = {
                        "*"             = "allow";
                        "~/.gnupg/**"   = "deny";
                        "~/.ssh/**"     = "deny";
                        "~/Shared/**"   = "deny";
                    };
                    edit = {
                        "*"             = "ask";
                        "~/.gnupg/**"   = "deny";
                        "~/.ssh/**"     = "deny";
                        "~/Shared/**"   = "deny";
                    };
                };
            };
        };
    }];
}
