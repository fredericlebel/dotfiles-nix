{ user, ... }:
{
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
      "mas"
      "pinentry-touchid"
      "wifi-password"
    ];

    casks = [
      # Communication & Navigation
      "discord"
      "google-chrome"
      "spotify"
      "zoom"

      # terminals
      "ghostty"

      # Développement & Tech
      "caido" # Sécurité / Proxy
      "maccy" # Gestionnaire de presse-papier
      "pgadmin4" # PostgreSQL
      "podman-desktop" # Alternative Docker
      #"visual-studio-code"
      "wireshark-app" # Analyse réseau

      # Productivité & Système
      "alt-tab" # Gestionnaire de fenêtres Windows-style
      "bitwarden" # Gestionnaire de mots de passe
      "google-drive"

      # Fonts (Typographies)
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"
    ];

    # --- Mac App Store (Identifiants numériques) ---
    masApps = {
      "Bitwarden" = 1352778147;
      "Tailscale" = 1475387142;
    };
  };
}
