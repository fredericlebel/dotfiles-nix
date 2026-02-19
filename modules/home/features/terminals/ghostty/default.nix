{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.terminals.ghostty;
in
{
  options.my.features.terminals.ghostty = {
    enable = lib.mkEnableOption "ghostty";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null;

      settings = {
        theme = "Catppuccin mocha";
        font-family = "FiraCode Nerd Font Mono";
        font-size = 13;
        window-padding-x = 10;
        window-padding-y = 10;
        command = "${pkgs.zsh}/bin/zsh";
        mouse-hide-while-typing = true;
        confirm-close-surface = false;
      };
    };
  };
}
