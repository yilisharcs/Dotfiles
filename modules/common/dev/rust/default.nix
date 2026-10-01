{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled getExe;
  cratesIoPath = config.age.secrets.crates-io.path;
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
  age.secrets.crates-io = {
    file = ./crates-io-auth-toml.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  home-manager.sharedModules = [
    ({config, ...}: {
      programs.cargo = enabled {
        package = fenixToolchain;
        settings = {
          unstable.rustc-unicode = true;
          build.rustc-wrapper = "${getExe pkgs.sccache}";
          target.x86_64-unknown-linux-gnu = {
            rustflags = [
              "-C"
              "target-cpu=native"
            ];
          };
        };
      };

      home.file.".cargo/credentials.toml".source =
        config.lib.file.mkOutOfStoreSymlink cratesIoPath;
    })
  ];
}
