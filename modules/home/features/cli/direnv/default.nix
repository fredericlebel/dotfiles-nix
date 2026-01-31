{
  lib,
  config,
  ...
}: let
  cfg = config.my.features.cli.direnv;
in {
  options.my.features.cli.direnv = {
    enable = lib.mkEnableOption "direnv avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
