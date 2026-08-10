{
  config,
  user,
  lib,
  ...
}:
{
  imports = [
    ./disko.nix

    ../../users/${user}/system.nix

    ../../modules/nixos/bundles/vps-base.nix
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

  # Activation du bundle VPS de base
  my.bundles.vps-base.enable = true;

  networking.hostName = "ix";

  users.users.${user}.extraGroups = [ "docker" ];
}
