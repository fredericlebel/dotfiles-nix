{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.bundles.desktop;
in {
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
    my.features.cli.bat.enable = true;
    my.features.cli.direnv.enable = true;
    my.features.cli.eza.enable = true;
    my.features.cli.fzf.enable = true;
    my.features.cli.htop.enable = true;
    my.features.cli.screen.enable = true;
    my.features.cli.starship.enable = true;
    my.features.cli.yazi.enable = true;
    my.features.cli.zsh.enable = true;

    my.features.dev.git.enable = true;
    my.features.dev.gpg.enable = true;
    my.features.dev.k9s.enable = true;

    my.features.editors.neovim.enable = true;

    my.features.terminals.wezterm.enable = true;

    # Tu n'actives PAS vscode sur un serveur, même si le module est importé
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
