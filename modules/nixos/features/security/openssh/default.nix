{
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.security.openssh;
in
{
  options.my.features.security.openssh = {
    enable = lib.mkEnableOption "OpenSSH durci (Post-Quantum & Key-only)";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;

      openFirewall = true;

      settings = {
        PermitRootLogin = "prohibit-password";

        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;

        AllowAgentForwarding = false;
        AllowTcpForwarding = true;
        X11Forwarding = false;

        KexAlgorithms = [
          "sntrup761x25519-sha512@openssh.com"
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];

        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
        ];

        MaxAuthTries = 3;

        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
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
