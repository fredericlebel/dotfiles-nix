{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.dev.ghq;
in
{
  options.my.features.dev.ghq = {
    enable = lib.mkEnableOption "Gestionnaire de dépôts Git ghq avec intégration Zsh et FZF";

    root = lib.mkOption {
      type = lib.types.str;
      default = "~/repositories";
      description = "Répertoire racine où ghq clone les dépôts.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ghq ];

    programs.git.settings = {
      ghq = {
        inherit (cfg) root;
      };
    };

    programs.zsh.initContent = ''
      if [[ -o interactive ]]; then
        ghq-fzf() {
          local repo
          repo="$(ghq list --full-path | fzf --preview 'head -n 30 {}/README.md 2>/dev/null || ls -la {}')"
          if [ -n "$repo" ]; then
            cd "$repo"
            zle reset-prompt 2>/dev/null || true
          fi
        }
        zle -N ghq-fzf
        bindkey '^g' ghq-fzf
      fi
    '';
  };
}
