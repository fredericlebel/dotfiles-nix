{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home/bundles/server.nix
  ];
  home = {
    homeDirectory = "/home/flebel";

    stateVersion = "26.05";
  };

  my.bundles.server.enable = true;
}
