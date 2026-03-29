{
  config,
  lib,
  ...
}:
let
  cfg = config.my.bundles.server;
in
{
  imports = [
    ../features/cli/core-utils.nix
    ../features/cli/htop.nix
    ../features/cli/screen.nix
    ../features/cli/starship.nix
    ../features/cli/yazi.nix
    ../features/cli/zsh.nix
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
        core-utils.enable = true;
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
      };
    };
  };
}
