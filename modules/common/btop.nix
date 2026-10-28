{lib, ...}: let
  inherit (lib) enabled;
in {
  home-manager.sharedModules = [
    {
      # Colorful resource monitor. Easier to read than htop.
      programs.btop = enabled {
        settings = {
          color_theme = "adapta";
          vim_keys = true;
          shown_boxes = "cpu proc net mem";
          update_ms = 1000;
          proc_sorting = "memory";
          proc_gradient = false;
          proc_per_core = true;
          proc_filter_kernel = true;
          cpu_graph_lower = "total";
          cpu_single_graph = true;
          mem_graphs = false;
          io_graph_combined = true;
        };
      };
    }
  ];
}
