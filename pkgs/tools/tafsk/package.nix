{ lib
, pkgs
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "tafsk";
    version = "0.3.0";

    src = pkgs.fetchFromGitHub {
        owner = "yilisharcs";
        repo = finalAttrs.pname;
        tag = finalAttrs.version;
        hash = "sha256-0mS1LV5sggtQxvPrmkSIQ/Gn36NohlARqKn5yKkynwE=";
    };

    cargoHash = "sha256-NEuWGijkzim9NLB2vezZpXZ4L8bKYvCCNiGUx7glIeI=";

    postInstall = ''
        ln -s $out/bin/tafsk $out/bin/task
    '';

    meta = {
        description = "Organize tasks like a file system";
        homepage = "https://github.com/yilisharcs/tafsk";
        license = lib.licenses.gpl3Only;
        # maintainers = with lib.maintainers; [ ];
        mainProgram = finalAttrs.pname;
    };
})
