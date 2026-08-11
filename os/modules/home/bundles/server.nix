{
  config,
  lib,
  ...
}:
let
  cfg = config.my.bundles.server;
in
{
  imports = [ ];

  options.my.bundles.server = {
    enable = lib.mkEnableOption "Bundle d'outils essentiels pour serveur (CLI)";
  };

  config = lib.mkIf cfg.enable {
    my.features = {
      zsh.enable = true;
      cli = {
        core-utils.enable = true;
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
      };
    };
  };
}
