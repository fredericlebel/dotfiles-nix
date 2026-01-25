{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../modules/darwin/system-defaults
    ../../modules/darwin/homebrew
    ../../modules/darwin/aerospace
    ../../modules/darwin/logseq
  ];

  # The "What"
  my.features = {
    aerospace.enable = true;
    logseq.enable = true;
  };

  # The "Where"
  system.defaults.dock.persistent-apps = [
    "/Applications/Google Chrome.app"
    "/Users/flebel/Applications/Home\ Manager\ Apps/Visual\ Studio \Code.app"
    "/Users/flebel/Applications/Home\ Manager\ Apps/WezTerm.app"
    "/Applications/Logseq.app"
    "/Applications/Spotify.app"
    "/Applications/Discord.app"
    "/Applications/Bitwarden.app"
    "/System/Applications/System Settings.app"
  ];

  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
}
