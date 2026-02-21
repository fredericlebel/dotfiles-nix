{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.provision.cli.zsh;
in
{
  options.my.features.provision.cli.zsh = {
    enable = lib.mkEnableOption "Zsh System Support";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };

    environment.shells = with pkgs; [ zsh ];

    environment.systemPackages = with pkgs; [
      zsh
      zsh-syntax-highlighting
      zsh-autosuggestions
    ];

    users.defaultUserShell = pkgs.zsh;
  };
}
