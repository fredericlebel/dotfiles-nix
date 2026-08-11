{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.features.provision.admin-cli;
in
{
  options.my.features.provision.admin-cli.enable = lib.mkEnableOption "System-wide Admin CLI tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      htop
      btop
      curl
      restic
      ghostty.terminfo
    ];
  };
}
