{
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix

    ../../users/flebel/system.nix

    ../../modules/nixos/bundles/base-server.nix
    ../../modules/nixos/features/infrastructure/caddy
    ../../modules/nixos/features/infrastructure/home-assistant
    ../../modules/nixos/features/infrastructure/observability
    ../../modules/nixos/features/infrastructure/security/openssh
    ../../modules/nixos/features/infrastructure/security/suricata
    ../../modules/nixos/features/infrastructure/tailscale
    ../../modules/nixos/features/infrastructure/vaultwarden
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

      extraInputRules = ''
        tcp dport 22 ct state new,untracked limit rate 3/minute accept
        tcp dport 22 drop
      '';
    };
    nftables.enable = true;
  };

  my.features = {
    caddy.tailscaleAuthFile = config.sops.secrets.tailscale-key.path;

    home-assistant = {
      enable = true;
      subdomain = "hass";
    };

    observability = {
      enable = true;
      role = "server";
      subdomain = "grafana";
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

    vaultwarden = {
      enable = true;
      subdomain = "vault";
    };
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
