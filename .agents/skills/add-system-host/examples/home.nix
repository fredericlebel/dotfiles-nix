{
  user,
  ...
}:
{
  imports = [
    ../../users/${user}/home.nix
    # Activer des bundles d'applications utilisateur si nécessaire
    # ../../modules/home/bundles/desktop.nix
  ];

  # my.bundles.desktop.enable = true;
}
