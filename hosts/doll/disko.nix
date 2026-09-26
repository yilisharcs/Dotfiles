{...}: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-CT500MX500SSD1_2028E2B5D2C0";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            priority = 1;
            start = "1M";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd"];
                };
                "@/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd"];
                };
                "@/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
}
