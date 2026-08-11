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
    infrastructure.tailscale.authKeyFile = config.sops.secrets.tailscale-key.path;
    infrastructure.postgresql.userPasswordFiles = {
      opentofu = config.sops.secrets.postgres-opentofu-password.path;
    };
  };

  # Activation du bundle VPS de base
  my.bundles.vps-base.enable = true;

  networking.hostName = "ecaz";

  sops.secrets.postgres-opentofu-password = {
    owner = "postgres";
    mode = "0400";
  };
}
