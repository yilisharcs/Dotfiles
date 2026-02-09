{ lib, ... }: let
    inherit (lib) disabled enabled;
in {
    home-manager.sharedModules = [{
        # Peer-to-peer file sync
        services.syncthing = enabled {
            overrideDevices = true;
            overrideFolders = false;
            settings = {
                options = {
                    localAnnounceEnabled = true;
                    urAccepted = 3;
                };
                devices = {
                    "gato".id = "PSZRSLV-R2BLQN3-WBAE4KB-EE5B2KI-2262MTR-JUSJSG3-VR2FPWE-PPROMAO";
                    "ouro".id = "WCU5IG3-OADNVR5-VXUIKMU-7DL3O3Y-GAFSCKW-EMFQV4P-4JGXYF4-ZK3TFAO";
                    "zany".id = "MF6IH63-BX3WP45-ZH42ZJM-ZKA45EZ-JNDUF5L-ZDLO5KH-H5B6XRJ-O4CTEQW";
                };
                folders = {
                    "Shared" = enabled {
                        devices = [
                            "gato"
                            "ouro"
                            "zany"
                        ];
                        id = "wacmh-5jzrh";
                        path = "~/Shared";
                        versioning = {
                            type = "trashcan";
                            params.cleanoutDays = "30";
                        };
                    };
                };
            };
        };
    }];
}
