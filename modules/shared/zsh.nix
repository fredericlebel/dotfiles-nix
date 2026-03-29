{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.zsh;
  isHomeManager = lib.hasAttr "home" config;
in
{
  options.my.features.zsh = {
    enable = lib.mkEnableOption "Zsh unified configuration (shared)";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Configuration partagée (plugins, omz, etc.)
      {
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
        };
      }

      # Spécificités Home Manager (config interactive)
      (lib.mkIf isHomeManager {
        programs.zsh = {
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
              "git"
              "git-flow"
              "git-flow-avh"
              "sudo"
            ];
          };

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
      })

      # Spécificités NixOS (System support)
      (lib.mkIf (!isHomeManager) {
        programs.zsh.enableBashCompletion = true;
        environment.shells = [ pkgs.zsh ];
        environment.systemPackages = with pkgs; [
          zsh
          zsh-syntax-highlighting
          zsh-autosuggestions
        ];
        users.defaultUserShell = pkgs.zsh;
      })
    ]
  );
}
