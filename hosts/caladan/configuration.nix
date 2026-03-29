{
  user,
  hostSpec,
  ...
}:
{
  imports = [
    ../../modules/darwin/bundles/laptop.nix
  ];

  # On branche les options sur la Spec unifiée
  my.features = hostSpec.features or { };

  # Activation manuelle du bundle (importé via imports)
  my.bundles.laptop.enable = true;

  users.users.${user} = {
    home = "/Users/${user}";
  };

  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

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
