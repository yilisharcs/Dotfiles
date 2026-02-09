{ pkgs, ... }: let
    backup = "backup";
in {
    services.btrbk.instances.backup = {
        onCalendar = "daily";
        snapshotOnly = true;
        settings = {
            volume."/home" = {
                snapshot_dir = ".snapshots";
                subvolume.".".target = "/run/media/yilisharcs/Saturn/" + backup;
            };
            stream_compress = "zstd";
            snapshot_preserve_min = "2d";
            snapshot_preserve = "14d";
            target_preserve_min = "no";
            target_preserve = "20d 10w 6m";
        };
    };

    environment.systemPackages = [
        (pkgs.writeShellScriptBin "backdown" ''
            sudo mkdir -p /home/.snapshots # Ensure local directory exists

            if ! mountpoint -q /run/media/yilisharcs/Saturn; then
                echo "[error]: Backup drive 'Saturn' is not mounted at /run/media/yilisharcs/Saturn!"
                exit 1
            fi

            sudo mkdir -p /run/media/yilisharcs/Saturn/${backup} # Ensure target directory exists

            sudo btrbk -c /etc/btrbk/${backup}.conf resume
            echo "Backup complete."
        '')
    ];
}
