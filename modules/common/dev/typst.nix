{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.typst # Markup-based typesetting system
        pkgs.tinymist # Integrated language service for Typst
        pkgs.websocat # Command-line client for WebSockets (deps: typst-preview.nvim)
      ];
    }
  ];
}
