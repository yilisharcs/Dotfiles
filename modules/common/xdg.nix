{pkgs, ...}: {
  # Set of command line tools that assist applications with a variety of desktop integration tasks
  # provides `xdg-open`
  environment.systemPackages = [pkgs.xdg-utils];

  home-manager.sharedModules = [
    {
      xdg.enable = true;

      xdg.dataFile."mime/packages/jsonc.xml".text =
        /*
        xml
        */
        ''
          <?xml version="1.0" encoding="UTF-8"?>
          <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
            <mime-type type="application/x-jsonc">
              <comment>JSON with Comments</comment>
              <sub-class-of type="application/json"/>
              <glob pattern="*.jsonc"/>
            </mime-type>
          </mime-info>
        '';
    }
  ];
}
