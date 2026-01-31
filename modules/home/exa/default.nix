{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.eza;
in
{
  options.my.features.eza = {
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
