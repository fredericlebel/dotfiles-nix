{
  user,
  config,
  ...
}:
{
  config = {
    system = {
      defaults = {
        NSGlobalDomain.NSWindowResizeTime = 0.001;
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
          # Consommation automatique du registre
          persistent-apps = [
            "/System/Applications/System Settings.app"
          ]
          ++ (builtins.filter (x: x != null) config.my.registry.dockApps);
        };
      };
      stateVersion = 4;

      primaryUser = user;
    };

    users.users."${user}" = {
      name = user;
      home = "/Users/${user}";
    };

    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
