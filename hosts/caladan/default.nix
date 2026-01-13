{
  pkgs,
  user,
  ...
}: {
  users.users."${user}" = {
    name = user;
    home = "/Users/${user}";
  };

  imports = [
    ../../modules/features/aerospace
    ../../modules/features/git
    ../../modules/features/logseq
    ../../modules/features/nix-maintenance
    ../../modules/features/tailscale
    ../../modules/features/wezterm
  ];

  my.features = {
    aerospace.enable = true;
    git.enable = true;
    logseq.enable = true;
    nix-maintenance.enable = true;
    tailscale.enable = true;
    wezterm.enable = true;
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
        autohide-time-modifier = 0.0;
        autohide-delay = 0.0;
        mru-spaces = false;
        persistent-apps = [
          "/Applications/Google Chrome.app"
          "/Applications/Nix Apps/WezTerm.app"
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
      "jorgelbg/tap"
      "nikitabobko/tap"
    ];

    brews = [
      "mas"
      "pinentry-touchid"
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
      "wireshark-app"

      # Productivité & Système
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
