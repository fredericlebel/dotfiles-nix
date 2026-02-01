{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.cli.eza;
in
{
  options.my.features.cli.eza = {
    enable = lib.mkEnableOption "eza avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true; # Crée l'alias 'ls' automatiquement
      icons = "auto"; # Affiche les icônes (nécessite Nerd Font)
      git = true; # Affiche le statut git des fichiers
    };
  };
}
