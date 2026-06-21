{
  config,
  user,
  lib,
  ...
}:
{
  imports = [
    # Charger les modules et bundles nécessaires
    ../../users/${user}/system.nix
    # ../../modules/darwin/bundles/laptop.nix (si Darwin)
    # ../../modules/nixos/bundles/base-server.nix (si NixOS)
  ];

  # Fusionner les features définies dans la spec
  my.features = config.myMeta.hostSpec.features or { };

  # Configurer l'utilisateur système
  users.users.${user} = {
    home = if config.myMeta.isDarwin then "/Users/${user}" else "/home/${user}";
  };

  # Déclarations additionnelles (secrets, réseau, etc.)
}
