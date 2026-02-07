{
  config,
  pkgs,
  modulesPath,
  myMeta,
  user,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix

    ../../users/flebel/system.nix

    ../../modules/nixos/bundles/base-server.nix

    ../../modules/nixos/features/observability
    ../../modules/nixos/features/home-assistant
    ../../modules/nixos/features/tailscale
    ../../modules/nixos/features/vaultwarden
    ../../modules/nixos/features/security/suricata
  ];

  my.bundles.base-server.enable = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "ix";
    domain = "opval.com";

    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
      trustedInterfaces = [ "tailscale0" ];

      extraInputRules = ''
        tcp dport 22 ct state new,untracked limit rate 3/minute accept
        tcp dport 22 drop
      '';
    };
    nftables.enable = true;
  };

  my.features.home-assistant.enable = true;

  my.features = {
    observability = {
      enable = true;
      role = "server";
    };

    security.suricata = {
      enable = true;
      interface = "ens3";
    };

    tailscale = {
      enable = true;
      isExitNode = true;
      authKeyFile = config.sops.secrets.tailscale-key.path;
    };

    vaultwarden.enable = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

  sops.secrets.tailscale-key = { };

  sops = {
    defaultSopsFile = ../../secrets/ix.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  system.stateVersion = "26.05";
}
