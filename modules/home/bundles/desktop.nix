{
  config,
  lib,
  ...
}:
let
  cfg = config.my.bundles.desktop;
in
{
  imports = [
    ../features/cli/core-utils.nix
    ../features/cli/desktop-utils.nix
    ../features/cli/htop.nix
    ../features/cli/screen.nix
    ../features/cli/starship.nix
    ../features/cli/yazi.nix
    ../../shared/zsh.nix
    ../features/dev
    ../features/editors
    ../features/terminals
  ];

  options.my.bundles.desktop = {
    enable = lib.mkEnableOption "Bundle d'outils essentiels pour desktop";
  };

  config = lib.mkIf cfg.enable {
    my.features = {
      zsh.enable = true;
      cli = {
        core-utils.enable = true;
        desktop-utils.enable = true;
        htop.enable = true;
        screen.enable = true;
        starship.enable = true;
        yazi.enable = true;
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
      terminals = {
        ghostty.enable = true;
      };
    };
  };
}
