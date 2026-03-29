{
  user,
  lib,
  config,
  ...
}:
let
  cfg = config.my.features.homebrew;
in
{
  options.my.features.homebrew = {
    enable = lib.mkEnableOption "Homebrew & Casks Support";
  };

  config = lib.mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      inherit user;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;

      onActivation = {
        cleanup = "zap";
        autoUpdate = true;
        upgrade = true;
      };

      taps = [
        "jorgelbg/tap"
      ];

      brews = [
        "pinentry-touchid"
        "wifi-password"
      ];

      casks = [
        # Communication & Navigation
        "discord"
        "google-chrome"
        "spotify"
        "zoom"

        # Développement & Tech
        "caido" # Sécurité / Proxy
        "maccy" # Gestionnaire de presse-papier
        "pgadmin4" # PostgreSQL
        "podman-desktop" # Alternative Docker
        "wireshark-app" # Analyse réseau

        # Productivité & Système
        "alt-tab" # Gestionnaire de fenêtres Windows-style
        "bitwarden"
        "google-drive"

        # Fonts (Typographies)
        "font-fira-code"
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
      ];
    };
  };
}
