{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.htop;
in
{
  options.my.features.htop = {
    enable = lib.mkEnableOption "htop avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.htop.enable = true;
  };
}
