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

  options.my.features.editors.vscode = {
    enable = lib.mkEnableOption "VS Code (stable) via Homebrew Cask";
    insiders.enable = lib.mkEnableOption "VS Code Insiders via Homebrew Cask";
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
        "wireshark-app" # Analyse réseau

        # Productivité & Système
        "alt-tab" # Gestionnaire de fenêtres Windows-style
        "bitwarden"
        "google-drive"

        # Fonts (Typographies)
        "font-fira-code"
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
      ]
      ++ lib.optional (config.my.features.editors.vscode.enable or false) "visual-studio-code"
      ++ lib.optional (config.my.features.editors.vscode.insiders.enable or false
      ) "visual-studio-code-insiders";
    };

    my.registry.dockApps = [
      "/Applications/Google Chrome.app"
      "/Applications/Spotify.app"
      "/Applications/Discord.app"
      "/Applications/Bitwarden.app"
    ];
  };
}
