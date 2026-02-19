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
    homebrew.casks = [
      "ghostty"
    ];

    programs.ghostty = {
      enable = true;
      package = null;

      settings = {
        theme = "catppuccin-mocha";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        window-padding-x = 10;
        window-padding-y = 10;
        command = "${pkgs.zsh}/bin/zsh";
        mouse-hide-while-typing = true;
        confirm-close-surface = false;
      };
    };

    home.packages = [ pkgs.ghostty ];
  };
}
