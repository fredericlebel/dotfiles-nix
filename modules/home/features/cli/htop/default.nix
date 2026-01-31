{
  lib,
  config,
  ...
}: let
  cfg = config.my.features.cli.htop;
in {
  options.my.features.cli.htop = {
    enable = lib.mkEnableOption "htop avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.htop.enable = true;
  };
}
