{
  lib,
  config,
  ...
}: let
  cfg = config.my.features.fzf;
in {
  options.my.features.fzf = {
    enable = lib.mkEnableOption "fzf avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true; # TODO dependency
      enableZshIntegration = true;
    };
  };
}
