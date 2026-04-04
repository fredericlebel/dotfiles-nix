{
  user,
  config,
  ...
}:
{
  imports = [
    ../../modules/darwin/bundles/laptop.nix
  ];

  # On branche les options sur la Spec unifiée
  my.features = config.myMeta.hostSpec.features or { };

  # Activation manuelle du bundle (importé via imports)
  my.bundles.laptop.enable = true;

  users.users.${user} = {
    home = "/Users/${user}";
  };

  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
}
