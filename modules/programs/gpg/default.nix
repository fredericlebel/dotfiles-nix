{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.gpg;
in {
  options.my.programs.gpg = {
    enable = lib.mkEnableOption "GPG et GPG Agent configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;

      pinentry.package = pkgs.pinentry_mac;

      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
    };

    home.sessionVariables = {
      GPG_TTY = "$(tty)";
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
    };

    # Optionnel : Si tu veux un fichier gpg.conf spécifique, tu peux le gérer ici aussi
    # home.file.".gnupg/gpg.conf".source = ./gpg.conf;
  };
}
