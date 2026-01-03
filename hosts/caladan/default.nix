{
  pkgs,
  user,
  ...
}: {
  users.users."${user}" = {
    name = user;
    home = "/Users/${user}";
  };

  system = {
    stateVersion = 4;
    primaryUser = user;

    defaults = {
      NSGlobalDomain = {
        NSWindowResizeTime = 0.001;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };

      dock = {
        autohide = true;
        mru-spaces = false;
        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/Applications/WezTerm.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Logseq.app"
          "/Applications/Spotify.app"
          "/Applications/Discord.app"
          "/Applications/Bitwarden.app"
          "/System/Applications/System Settings.app"
        ];
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  nix.enable = false;

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

    taps = [
      "nikitabobko/tap"
    ];

    brews = [
      "mas"
      "wifi-password"
    ];

    casks = [
      # Navigateurs & Com
      "discord"
      "google-chrome"
      "spotify"
      "zoom"

      # Outils Tech
      "caido"
      "maccy"
      "pgadmin4"
      "podman-desktop"
      "visual-studio-code"
      "wezterm"
      "wireshark-app"

      # Productivité & Système
      "aerospace"
      "alt-tab"
      "bitwarden"
      "google-drive"
      "logseq"

      # Fonts
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"
    ];

    masApps = {
      "Bitwarden" = 1352778147;
      "Tailscale" = 1475387142;
    };
  };
}
