{
  user,
  ...
}:
{
  imports = [
    ../../modules/darwin/bundles/laptop.nix
  ];

  users.users.${user} = {
    home = "/Users/${user}";
  };

  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  # The "What"
  my.features = {
    aerospace.enable = true;
    logseq.enable = true;
    terminals.ghostty.enable = true;
  };

  # The "Where"
  system.defaults.dock.persistent-apps = [
    "/Applications/Google Chrome.app"
    "/Applications/Ghostty.app"
    "/Users/flebel/Applications/Home\ Manager\ Apps/Visual\ Studio \Code.app"
    "/Applications/Logseq.app"
    "/Applications/Spotify.app"
    "/Applications/Discord.app"
    "/Applications/Bitwarden.app"
    "/System/Applications/System Settings.app"
  ];
}
