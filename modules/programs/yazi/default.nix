{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.yazi;
in {
  options.my.programs.yazi = {
    enable = lib.mkEnableOption "Yazi Terminal File Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        manager = {
          show_hidden = true; # Afficher les fichiers cachés par défaut
          sort_by = "natural"; # Tri naturel (file1, file2, file10)
          sort_dir_first = true; # Dossiers en haut
          linemode = "size"; # Affiche la taille à côté du nom
        };

        preview = {
          tab_size = 2;
          max_width = 1000;
          max_height = 1000;
        };
      };

      # Optionnel : Si tu veux fixer un thème spécifique
      # theme = { ... };
    };
  };
}
