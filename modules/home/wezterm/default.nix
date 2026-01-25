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
    home.packages = with pkgs; [
      # Installe les deux pour comparer
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];

    programs.wezterm = {
      enable = true;
      package = pkgs.wezterm;
      enableBashIntegration = true;
      enableZshIntegration = true;

      extraConfig = ''
        local wezterm = require 'wezterm'
        local config = wezterm.config_builder()

        -- Apparence
        config.color_scheme = "Catppuccin Macchiato"
        config.font = wezterm.font('JetBrains Mono')
        config.font_size = 13.0
        config.line_height = 1.2
        config.window_background_opacity = 0.95

        -- UI/UX
        config.hide_tab_bar_if_only_one_tab = true
        -- Adapté pour AeroSpace ou gestionnaires de fenêtres
        config.window_decorations = "RESIZE"

        -- Rendu texte
        config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

        return config
      '';
    };
  };
}
