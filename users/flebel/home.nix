{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    homeDirectory = lib.mkForce (if pkgs.stdenv.isDarwin then "/Users/flebel" else "/home/flebel");
    packages = [ pkgs.restic ];

    stateVersion = "26.05";
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/common.yaml;
  };
}
