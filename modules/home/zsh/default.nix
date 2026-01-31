{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.zsh;
in
{
  options.my.features.zsh = {
    enable = lib.mkEnableOption "Zsh configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 100000;
        save = 100000;
        path = "${config.xdg.dataHome}/zsh/history";
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "direnv"
          "docker"
          "docker-compose"
          "git"
          "git-flow"
          "git-flow-avh"
          "sudo"
        ];
      };

      #system.sessionVariables = {
      #  SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
      #};

      #shellInit = ''
      #  export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
      #'';

      sessionVariables = {
        SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
      };

      initContent = lib.mkBefore ''
        ssh-production() {
          # Change terminal background to dark red
          printf '\033]11;#3d1515\007'
          command ssh "$@"
          # Reset terminal background
          printf '\033]11;#1f2528\007'
        }
      '';
    };
  };
}
