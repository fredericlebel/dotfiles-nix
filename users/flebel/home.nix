{
  config,
  lib,
  pkgs,
  user,
  myMeta,
  ...
}:
{
  home = {
    homeDirectory = lib.mkForce (if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}");
    packages = with pkgs; [
      restic
      bitwarden-cli
    ];

    stateVersion = myMeta.defaultStateVersion;
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/common.yaml;
  };
}
