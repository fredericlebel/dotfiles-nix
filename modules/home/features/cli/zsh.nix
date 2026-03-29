{
  config,
  lib,
  ...
}:
{
  imports = [ ../../../shared/zsh.nix ];

  options.my.features.cli.zsh = {
    enable = lib.mkEnableOption "Zsh configuration (deprecated, use my.features.zsh.enable)";
  };

  config.my.features.zsh.enable = config.my.features.cli.zsh.enable;
}
