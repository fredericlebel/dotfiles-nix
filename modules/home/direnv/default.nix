{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.direnv;
in
{
  options.my.features.direnv = {
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
