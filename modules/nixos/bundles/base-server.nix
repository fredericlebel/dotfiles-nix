{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.my.bundles.base-server;
  myKeys = import ../../../modules/shared/keys.nix;
in
{
  imports = [
    ../features/provision/admin-cli.nix
    ../../shared/zsh.nix
    ../features/infrastructure/security/hardening.nix
    ../features/infrastructure/security/intrusion-detection.nix
    ../features/infrastructure/security/openssh.nix
    ../features/infrastructure/security/fail2ban.nix
    ../features/infrastructure/nix-core.nix
    ../features/infrastructure/virtualization/kvm.nix
  ];

  options.my.bundles.base-server = {
    enable = lib.mkEnableOption "Configuration de base pour serveur";
  };

  config = lib.mkIf cfg.enable {
    my.features = {
      zsh.enable = true;
      provision = {
        admin-cli.enable = true;
      };
      infrastructure = {
        security = {
          hardening = {
            enable = true;
          };
          "intrusion-detection" = {
            enable = true;
          };
          openssh = {
            enable = true;
          };
          fail2ban = {
            enable = true;
          };
        };
        "nix-core" = {
          enable = true;
        };
        virtualization = {
          kvm = {
            enable = true;
          };
        };
      };
    };

    users.users.root.openssh.authorizedKeys.keys = [ myKeys.flebel ];

    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ user ];
          keepEnv = true;
          persist = true;
        }
      ];
    };
    security.sudo.wheelNeedsPassword = false;

    time.timeZone = "America/Montreal";
  };
}
