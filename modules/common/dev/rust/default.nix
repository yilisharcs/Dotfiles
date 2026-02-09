{ lib, pkgs, ... }: let
    inherit (lib) disabled enabled getExe;
    fenixToolchain = pkgs.fenix.combine [
        pkgs.fenix.complete.cargo
        pkgs.fenix.complete.clippy
        pkgs.fenix.complete.rust-analyzer
        pkgs.fenix.complete.rust-src
        pkgs.fenix.complete.rustc
        pkgs.fenix.complete.rustfmt

        pkgs.cargo-audit # Scan Cargo.lock for known security vulns
        pkgs.cargo-auditable # Embed dependency metadata in the final binary
        pkgs.cargo-modules # Produce tree-like view of the module structure
        pkgs.cargo-nextest
    ];
in {
    home-manager.sharedModules = [{
        programs.cargo = enabled {
            package = fenixToolchain;
            settings = {
                unstable.rustc-unicode = true;
                build.rustc-wrapper = "${getExe pkgs.sccache}";
                target.x86_64-unknown-linux-gnu = {
                    linker = "${getExe pkgs.clang}";
                    rustflags = [
                        "-C" "target-cpu=native"
                        "-C" "link-arg=-fuse-ld=${getExe pkgs.mold}"
                    ];
                };
            };
        };
    }];
}
