{ pkgs, user, ... }:
let
  myKeys = import ../../modules/shared/keys.nix;
in
{
  users = {
    groups.${user} = { };

    users.${user} = {
      isNormalUser = true;
      description = "Frédéric Lebel";
      group = user;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ myKeys.flebel ];
    };
  };
}
