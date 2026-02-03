{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.bundles.server;
in
{
  imports = [
    ../features/cli
    ../features/dev
    ../features/editors
    ../features/terminals
  ];

  options.my.bundles.server = {
    enable = lib.mkEnableOption "Bundle d'outils essentiels pour serveur (CLI)";
  };

  config = lib.mkIf cfg.enable {
    my.features = {
      cli = {
        bat.enable = true;
        direnv.enable = true;
        eza.enable = true;
        fzf.enable = true;
        htop.enable = true;
        screen.enable = true;
        starship.enable = true;
        yazi.enable = true;
        zsh.enable = true;
      };
      dev = {
        git.enable = true;
        k9s.enable = true;
      };

      editors.neovim.enable = true;
    };

    home.packages = with pkgs; [
      curl
      wget
      jq
      ripgrep
      fd
      ncdu
    ];
  };
}
