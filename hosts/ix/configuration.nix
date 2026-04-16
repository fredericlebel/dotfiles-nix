{
  config,
  modulesPath,
  user,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix

    ../../users/${user}/system.nix

    ../../modules/nixos/bundles/base-server.nix
    ../../modules/nixos/features/infrastructure/caddy.nix
    ../../modules/nixos/features/infrastructure/home-assistant.nix
    ../../modules/nixos/features/infrastructure/observability
    ../../modules/nixos/features/infrastructure/security/openssh.nix
    ../../modules/nixos/features/infrastructure/security/suricata.nix
    ../../modules/nixos/features/infrastructure/tailscale.nix
    ../../modules/nixos/features/infrastructure/vaultwarden.nix
  ];

  # On fusionne la Spec unifiée avec la config technique locale
  my.features = lib.recursiveUpdate (config.myMeta.hostSpec.features or { }) {
    infrastructure = {
      caddy.tailscaleAuthFile = config.sops.secrets.tailscale-key.path;
      tailscale.authKeyFile = config.sops.secrets.tailscale-key.path;
    };
  };

  # Activation manuelle du bundle (importé via imports)
  my.bundles.base-server.enable = true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  users.users.${user} = {
    extraGroups = [
      "wheel"
      "docker"
    ];
    home = "/home/${user}";
  };

  networking = {
    hostName = "ix";
    domain = "opval.com";

    firewall = {
      enable = true;
    };
    nftables.enable = true;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

  sops.secrets.tailscale-key = { };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  system.stateVersion = "26.05";
}
