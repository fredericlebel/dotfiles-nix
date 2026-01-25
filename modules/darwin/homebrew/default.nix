{user, ...}: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    # --- Sources externes ---
    taps = [
      "jorgelbg/tap"
      #"nikitabobko/tap" # Pour AeroSpace si installé via Brew
    ];

    # --- Utilitaires CLI (Brews) ---
    brews = [
      "mas" # Mac App Store CLI
      "pinentry-touchid" # GPG + TouchID integration
      "wifi-password" # Récupération rapide des clés WiFi
    ];

    # --- Applications Graphiques (Casks) ---
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
      #"visual-studio-code"
      "wireshark-app" # Analyse réseau

      # Productivité & Système
      "alt-tab" # Gestionnaire de fenêtres Windows-style
      "bitwarden" # Gestionnaire de mots de passe
      "google-drive"
      "logseq" # Base de connaissance

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
