{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.my.features.terminals.ghostty;
  isSystem = options ? environment;
  isHome = options ? home;
  megabytes_to_bytes = mb: mb * 1024 * 1024;
in
{
  options.my.features.terminals.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isSystem {
        environment.variables.TERMINFO_DIRS = [
          "/Applications/Ghostty.app/Contents/Resources/terminfo"
        ];
        homebrew = {
          enable = true;
          casks = [ "ghostty" ];
        };
      })

      (lib.optionalAttrs isHome {
        programs.ghostty = {
          enable = true;
          package = null;
          settings = {
            theme = "Catppuccin mocha";
            font-family = "FiraCode Nerd Font Mono";
            font-size = 13;
            window-padding-x = 10;
            window-padding-y = 10;
            macos-titlebar-proxy-icon = "hidden";
            command = "${pkgs.zsh}/bin/zsh";
            focus-follows-mouse = true;
            mouse-hide-while-typing = true;
            confirm-close-surface = false;
            scrollback-limit = megabytes_to_bytes 500;
            palette = [ "11=#c7c400" ];
          };
        };
      })
    ]
  );
}
