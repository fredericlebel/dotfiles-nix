{
  user,
  ...
}:
{
  imports = [
    ../../users/${user}/home.nix
    ../../modules/home/bundles/server.nix
  ];

  my.bundles.server.enable = true;
}
