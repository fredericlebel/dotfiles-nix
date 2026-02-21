{
  lib,
  pkgs,
  ...
}:
{
  home = {
    homeDirectory = lib.mkForce (if pkgs.stdenv.isDarwin then "/Users/flebel" else "/home/flebel");

    stateVersion = "26.05";
  };
}
