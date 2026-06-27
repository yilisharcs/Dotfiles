{config, ...}: {
  age.secrets.home-wifi = {
    file = ./home-wifi.age;
    owner = "yilisharcs";
    mode = "0400";
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [config.age.secrets.home-wifi.path];

    profiles.home-wifi = rec {
      connection = {
        id = "JesuseoCaminho";
        type = "wifi";
      };
      wifi.ssid = connection.id;
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PSK";
      };
    };
  };
}
