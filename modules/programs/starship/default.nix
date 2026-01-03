{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.starship;
in {
  options.my.programs.starship = {
    enable = lib.mkEnableOption "Starship prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        add_newline = false;

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };

        git_branch = {
          symbol = "🌱 ";
        };

        package = {
          disabled = true;
        };
      };
    };
  };
}
