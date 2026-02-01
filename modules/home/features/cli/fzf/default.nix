{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.cli.fzf;
in
{
  options.my.features.cli.fzf = {
    enable = lib.mkEnableOption "fzf avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true; # TODO dependency
      enableZshIntegration = true;
    };
  };
}
