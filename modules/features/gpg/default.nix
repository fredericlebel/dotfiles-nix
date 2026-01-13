{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.features.gpg;

  pinentry = pkgs.pinentry_mac;
in {
  options.my.features.gpg = {
    enable = lib.mkEnableOption "Configuration GPG avec Support Keychain/TouchID";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.gnupg
      pinentry
    ];

    programs.gpg = {
      enable = true;

      settings = {
        # --- UI / Comportement ---
        no-greeting = true;
        use-agent = true;
        no-comments = true;
        no-emit-version = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        fixed-list-mode = true;
        charset = "utf-8";

        # --- Crypto ---
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;

      pinentry.package = pinentry;
      #pinentry = {
      #  package = pkgs.pinentry-touchid;
      #  program = "pinentry-touchid";
      #};

      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;

      #extraConfig = ''
      #  pinentry-program ${pinentry}/bin/pinentry-mac
      #'';
    };

    programs.zsh.initContent = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
    '';
  };
}
