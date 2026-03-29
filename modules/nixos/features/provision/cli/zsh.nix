{
  config,
  lib,
  ...
}:
{
  imports = [ ../../../../shared/zsh.nix ];

  options.my.features.provision.cli.zsh = {
    enable = lib.mkEnableOption "Zsh System Support (deprecated, use my.features.zsh.enable)";
  };

  config.my.features.zsh.enable = config.my.features.provision.cli.zsh.enable;
}
