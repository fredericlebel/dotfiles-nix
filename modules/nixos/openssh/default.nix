{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.my.services.openssh;
in {
  options.my.services.openssh = {
    enable = lib.mkEnableOption "OpenSSH";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        X11Forwarding = false;

        KexAlgorithms = [
          "sntrup761x25519-sha512@openssh.com" # Post-quantique
          "curve25519-sha256" # Standard moderne
        ];

        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
        ];

        MaxAuthTries = 3;
        LoginGraceTime = 30;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 0;
      };

      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
