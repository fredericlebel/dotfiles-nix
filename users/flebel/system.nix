{
  pkgs,
  user,
  ...
}: let
  myKeys = import ../../modules/shared/keys.nix;
in {
  users.defaultUserShell = pkgs.zsh;
  users.groups.${user} = {};

  users.users.${user} = {
    isNormalUser = true;
    group = user;
    extraGroups = ["wheel" "podman"];
    openssh.authorizedKeys.keys = [myKeys.flebel];
  };
}
