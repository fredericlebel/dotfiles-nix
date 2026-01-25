{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.aerospace;
  mod = "alt";
in {
  options.my.features.aerospace = {
    enable = lib.mkEnableOption "Active AeroSpace Tiling Window Manager";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];

    services.aerospace = {
      enable = true;

      settings = {
        config-version = 2;

        after-login-command = [];
        after-startup-command = [];

        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        key-mapping.preset = "qwerty";

        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

        persistent-workspaces = lib.stringToCharacters "123456QWERTASDFGZXCVB";

        gaps = {
          inner.horizontal = 10;
          inner.vertical = 10;
          outer.left = 10;
          outer.bottom = 10;
          outer.top = 10;
          outer.right = 10;
        };

        mode.main.binding = {
          "${mod}-enter" = "exec-and-forget open -n /Applications/WezTerm.app";

          "${mod}-comma" = "layout tiles horizontal vertical";
          "${mod}-period" = "layout accordion horizontal vertical";

          "${mod}-h" = "focus left";
          "${mod}-j" = "focus down";
          "${mod}-k" = "focus up";
          "${mod}-l" = "focus right";
          "${mod}-f" = "fullscreen";

          "${mod}-shift-h" = "move left";
          "${mod}-shift-j" = "move down";
          "${mod}-shift-k" = "move up";
          "${mod}-shift-l" = "move right";

          "${mod}-shift-minus" = "resize smart -50";
          "${mod}-shift-equal" = "resize smart +50";

          "${mod}-1" = "workspace 1";
          "${mod}-2" = "workspace 2";
          "${mod}-3" = "workspace 3";
          "${mod}-4" = "workspace 4";
          "${mod}-5" = "workspace 5";
          "${mod}-6" = "workspace 6";
          "${mod}-q" = "workspace Q";
          "${mod}-w" = "workspace W";
          "${mod}-e" = "workspace E";
          "${mod}-r" = "workspace R";
          "${mod}-c" = "workspace C";
          "${mod}-v" = "workspace V";

          "${mod}-shift-1" = "move-node-to-workspace 1";
          "${mod}-shift-2" = "move-node-to-workspace 2";
          "${mod}-shift-3" = "move-node-to-workspace 3";
          "${mod}-shift-4" = "move-node-to-workspace 4";
          "${mod}-shift-5" = "move-node-to-workspace 5";
          "${mod}-shift-6" = "move-node-to-workspace 6";
          "${mod}-shift-q" = "move-node-to-workspace Q";
          "${mod}-shift-w" = "move-node-to-workspace W";
          "${mod}-shift-e" = "move-node-to-workspace E";
          "${mod}-shift-r" = "move-node-to-workspace R";
          "${mod}-shift-c" = "move-node-to-workspace C";
          "${mod}-shift-v" = "move-node-to-workspace V";

          "${mod}-tab" = "workspace-back-and-forth";
          "${mod}-shift-tab" = "move-workspace-to-monitor --wrap-around next";

          "${mod}-shift-semicolon" = "mode service";
        };

        mode.service.binding = {
          esc = ["reload-config" "mode main"];
          r = ["flatten-workspace-tree" "mode main"];
          f = ["layout floating tiling" "mode main"];
          backspace = ["close-all-windows-but-current" "mode main"];
        };

        on-window-detected = [
          {
            "if".app-id = "com.hnc.Discord";
            run = "move-node-to-workspace D";
          }
          {
            "if".app-id = "com.github.wez.wezterm";
            run = "move-node-to-workspace T";
          }
          {
            "if".app-id = "com.microsoft.VSCode";
            run = "move-node-to-workspace V";
          }
          {
            "if".app-id = "io.caido.Caido";
            run = "move-node-to-workspace C";
          }
          {
            "if".app-id = "com.apple.systempreferences";
            run = "layout floating";
          }
          {
            "if".app-id = "com.apple.finder";
            run = "layout floating";
          }
          {
            "if".app-id = "com.1password.1password";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "Picture-in-Picture";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "Open";
            run = "layout floating";
          }
        ];
      };
    };

    services.jankyborders = {
      enable = true;
      width = 6.0;
      active_color = "0xff88c0d0";
      inactive_color = "0xff4c566a";
      hidpi = true;
      blacklist = [
        "Float"
        "Spotlight"
      ];
    };

    services.skhd = {
      enable = true;

      skhdConfig = ''
        # --- WORKSPACES (Navigation) ---
        lalt - 1 : aerospace workspace 1
        lalt - 2 : aerospace workspace 2
        lalt - 3 : aerospace workspace 3
        lalt - 4 : aerospace workspace 4
        lalt - 5 : aerospace workspace 5
        lalt - 6 : aerospace workspace 6
        lalt - q : aerospace workspace Q
        lalt - w : aerospace workspace W
        lalt - e : aerospace workspace E
        lalt - r : aerospace workspace R
        lalt - c : aerospace workspace C
        lalt - v : aerospace workspace V

        lalt - h : aerospace focus --boundaries-action wrap-around-the-workspace left
        lalt - l : aerospace focus --boundaries-action wrap-around-the-workspace right
        lalt - k : aerospace focus --boundaries-action wrap-around-the-workspace up
        lalt - j : aerospace focus --boundaries-action wrap-around-the-workspace down

        lalt + shift - h : aerospace move left
        lalt + shift - l : aerospace move right
        lalt + shift - k : aerospace move up
        lalt + shift - j : aerospace move down

        ralt - l : pmset displaysleepnow
      '';
    };
  };
}
