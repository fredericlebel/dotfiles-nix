{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.bundles.desktop;
in
{
  imports = [
    ../features/cli
    ../features/dev
    ../features/editors
    ../features/terminals
  ];

  options.my.bundles.desktop = {
    enable = lib.mkEnableOption "Bundle d'outils essentiels pour desktop";
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
        gpg.enable = true;
        k9s.enable = true;
      };

      editors = {
        neovim.enable = true;
        vscode.enable = true;
      };
      terminals.wezterm.enable = true;
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
