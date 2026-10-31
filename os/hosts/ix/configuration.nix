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
  ];

  # On fusionne la Spec unifiée avec la config technique locale
  my.features = lib.recursiveUpdate (config.myMeta.hostSpec.features or { }) {
    infrastructure = {
      caddy.tailscaleAuthFile = config.sops.secrets.tailscale-key.path;
      tailscale.authKeyFile = config.sops.secrets.tailscale-key.path;
      home-assistant.eufy.envFile = config.sops.secrets.eufy-bridge-env.path;
      n8n.envFile = config.sops.secrets.n8n-env.path;
    };
  };

  sops.secrets.n8n-env = {
    owner = "root";
    mode = "0400";
  };

  sops.secrets.eufy-bridge-env = {
    owner = "root";
    mode = "0400";
  };

  # Activation du bundle VPS de base
  my.bundles.vps-base.enable = true;

  networking.hostName = "ix";

  users.users.${user}.extraGroups = [ "docker" ];
}
