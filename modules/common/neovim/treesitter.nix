{ ... }: {
    nixpkgs.overlays = [(final: prev: {
        # TODO: remove once upstream bumps version
        tree-sitter = prev.tree-sitter.overrideAttrs (finalAttrs: prevAttrs: rec {
            version = "0.26.5";

            src = prev.fetchFromGitHub {
                owner = "tree-sitter";
                repo = "tree-sitter";
                tag = "v${version}";
                hash = "sha256-tnZ8VllRRYPL8UhNmrda7IjKSeFmmOnW/2/VqgJFLgU=";
                fetchSubmodules = true;
            };

            nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [
                prev.clang
            ];

            env = (prevAttrs.env or { }) // {
                LIBCLANG_PATH = "${prev.llvmPackages.libclang.lib}/lib";
            };

            cargoHash = null;
            cargoDeps = prev.rustPlatform.fetchCargoVendor {
                inherit src;
                hash = "sha256-EU8kdG2NT3NvrZ1AqvaJPLpDQQwUhYG3Gj5TAjPYRsY=";
            };

            patches = [ ];
        });
    })];
}
