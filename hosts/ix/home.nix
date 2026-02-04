{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../users/flebel/home.nix
    ../../modules/home/bundles/server.nix
  ];

  my.bundles.server.enable = true;
}
