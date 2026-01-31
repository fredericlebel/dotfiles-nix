{ config, lib, pkgs, user, ... }:
let
  cfg = config.my.bundles.base-server;
in
{
  imports = [
    ../features/security/hardening.nix
    ../features/system/nix-maintenance.nix
    ../openssh
    ../zsh
    ../aide
  ];

  options.my.bundles.base-server = {
    enable = lib.mkEnableOption "Configuration de base pour serveur";
  };

  config = lib.mkIf cfg.enable {
    my.features.security.hardening.enable = true;
    my.features.system.nix-maintenance.enable = true;

    my.services.openssh.enable = true;
    programs.zsh.enable = true;

    security.doas = {
      enable = true;
      extraRules = [{ users = [ user ]; keepEnv = true; persist = true; }];
    };
    security.sudo.wheelNeedsPassword = false;

    time.timeZone = "America/Montreal";
  };
}
