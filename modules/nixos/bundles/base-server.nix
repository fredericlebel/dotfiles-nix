{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  cfg = config.my.bundles.base-server;
  myKeys = import ../../../modules/shared/keys.nix;
in {
  imports = [
    ../features/security/hardening.nix
    ../features/security/openssh
    ../features/system/nix-maintenance.nix
    ../zsh
    ../aide
  ];

  options.my.bundles.base-server = {
    enable = lib.mkEnableOption "Configuration de base pour serveur";
  };

  config = lib.mkIf cfg.enable {
    my.features.security.hardening.enable = true;
    my.features.security.openssh.enable = true;
    my.features.system.nix-maintenance.enable = true;

    programs.zsh.enable = true;

    users.users.root.openssh.authorizedKeys.keys = [myKeys.flebel];

    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [user];
          keepEnv = true;
          persist = true;
        }
      ];
    };
    security.sudo.wheelNeedsPassword = false;

    time.timeZone = "America/Montreal";
  };
}
