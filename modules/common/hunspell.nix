{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.hunspell # Spell checker
        pkgs.hunspellDicts.en_US # US English dictionary
        pkgs.hunspellDicts.pt_BR # Brazilian Portuguese dictionary
      ];
    }
  ];
}
