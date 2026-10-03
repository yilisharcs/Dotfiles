{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.temurin-bin # OpenJDK 21 LTS
        pkgs.jdt-language-server # Java LSP
        pkgs.google-java-format
        pkgs.maven # primary build tool
        pkgs.gradle # secondary build tool
      ];
    }
  ];
}
