{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.yazi;
in
{
  options.my.features.yazi = {
    enable = lib.mkEnableOption "Yazi Terminal File Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
          linemode = "size";
        };

        preview = {
          tab_size = 2;
          max_width = 1000;
          max_height = 1000;
        };
      };

      # theme = { ... };
    };
  };
}
