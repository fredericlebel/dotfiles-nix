{
  lib,
  config,
  pkgs,
  user,
  ...
}: let
  cfg = config.my.features.wezterm;
in {
  options.my.features.wezterm = {
    enable = lib.mkEnableOption "Wezterm Terminal";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wezterm
      pkgs.fira-code
    ];

    home-manager.users.${user} = {
      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;

        extraConfig = ''
          local wezterm = require 'wezterm'
          local config = wezterm.config_builder()

          -- Ta configuration convertie
          config.color_scheme = 'Solarized Dark Higher Contrast (Gogh)'
          config.font = wezterm.font('Fira Code')
          config.font_size = 15.0
          config.hide_tab_bar_if_only_one_tab = true

          -- UX : Puisque tu utilises AeroSpace, il est recommandé de
          -- désactiver les décorations natives (la barre de titre macOS)
          config.window_decorations = "RESIZE"

          return config
        '';
      };
    };
  };
}
