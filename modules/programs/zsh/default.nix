{ lib, config, pkgs, ... }:

let
  cfg = config.my.programs.zsh;
in
{
  options.my.programs.zsh = {
    enable = lib.mkEnableOption "Zsh configuration";
  };

  config = lib.mkIf cfg.enable {

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        save = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
        ignoreAllDups = true;
        share = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "docker" "docker-compose" "git" "git-flow" "git-flow-avh" "sudo" ];
      };
      initContent = ''
        bindkey -e

        # --- Styles de complétion avancés ---
        zstyle ':completion:*' auto-description 'specify: %d'
        zstyle ':completion:*' completer _expand _complete _correct _approximate
        zstyle ':completion:*' format 'Completing %d'
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*' menu select=2
        zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' list-colors ""
        zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
        zstyle ':completion:*' matcher-list "" 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
        zstyle ':completion:*' menu select=long
        zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
        zstyle ':completion:*' use-compctl false
        zstyle ':completion:*' verbose true
        zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
        zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

        # --- Fonctions Personnalisées ---
        bw-unlock() {
          export BW_SESSION=$(bw unlock | grep 'export BW_SESSION' | sed 's/$ export BW_SESSION="//' | sed 's/"//')
        }
      '';

      envExtra = ''
        if [ -f "$HOME/.cargo/env" ]; then
          . "$HOME/.cargo/env"
        fi
      '';
    };
  };
}
