{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.editors.neovim;
in {
  options.my.features.editors.neovim = {
    enable = lib.mkEnableOption "neovim avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;

      defaultEditor = true; # Définit nvim comme éditeur par défaut ($EDITOR)
      viAlias = true; # Crée un alias 'vi' -> 'nvim'
      vimAlias = true; # Crée un alias 'vim' -> 'nvim'

      # Pour ajouter des plugins (optionnel mais recommandé)
      plugins = with pkgs.vimPlugins; [
        vim-nix # Indispensable pour la coloration syntaxique de tes fichiers .nix
        # telescope-nvim    # Exemple d'autre plugin populaire
        # nvim-treesitter
      ];

      # Ta configuration personnalisée (Lua ou Vimscript)
      extraConfig = ''
        set number          " Affiche les numéros de ligne
        set relativenumber  " Numéros relatifs (pratique pour les sauts)
        set mouse=a         " Active la souris
        syntax on
      '';
    };
  };
}
