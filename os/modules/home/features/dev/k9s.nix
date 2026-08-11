{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.dev.k9s;
in
{
  options.my.features.dev.k9s = {
    enable = lib.mkEnableOption "k9s avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.k9s = {
      enable = true;
    };
  };
}
