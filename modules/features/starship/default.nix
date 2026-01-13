{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.features.starship;
in {
  options.my.features.starship = {
    enable = lib.mkEnableOption "Starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        add_newline = true;

        scan_timeout = 10;

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };

        git_branch = {
          symbol = "🌱 ";
        };

        git_status = {
          style = "red bold";
        };

        kubernetes = {
          disabled = false;
          style = "blue bold";
          symbol = "☸ ";
          # context_aliases = {
          #   "arn:aws:eks:..." = "prod";
          # };
        };

        python = {
          symbol = "🐍 ";
          detect_extensions = ["py"];
        };

        rust = {
          symbol = "🦀 ";
          style = "bold red";
        };

        package = {
          disabled = true;
        };

        cmd_duration = {
          min_time = 500; # Affiche la durée si la commande prend > 500ms
          show_notifications = true;
        };
      };
    };
  };
}
