{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.cli.starship;
in
{
  options.my.features.cli.starship = {
    enable = lib.mkEnableOption "Starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        #add_newline = true;
        username = {
          style_user = "blue bold";
          style_root = "red bold";
          format = "[$user]($style) ";
          disabled = false;
          show_always = false;
        };
        hostname = {
          ssh_only = true;
          format = "sur [$hostname](bold red) ";
          disabled = false;
        };
        format = "$username$hostname$directory$git_branch$character";

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
          detect_extensions = [ "py" ];
        };

        rust = {
          symbol = "🦀 ";
          style = "bold red";
        };

        package = {
          disabled = true;
        };

        cmd_duration = {
          min_time = 500;
          show_notifications = true;
        };
      };
    };
  };
}
