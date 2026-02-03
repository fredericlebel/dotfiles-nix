{ pkgs, user, ... }:
let
  myKeys = import ../../modules/shared/keys.nix;
in
{
  users = {
    defaultUserShell = pkgs.zsh;
    groups.${user} = { };

    users.${user} = {
      isNormalUser = true;
      group = user;
      extraGroups = [
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ myKeys.flebel ];
    };
  };
}
