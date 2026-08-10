{
  lib,
  config,
  ...
}:
let
  cfg = config.my.bundles.laptop;
in
{
  imports = [
    ../features/aerospace.nix
    ../features/provision/ghostty.nix
    ../features/provision/homebrew.nix
    ../features/provision/logseq.nix
    ../features/podman.nix
    ../features/system-defaults.nix
    ../features/antigravity-cli.nix
    ../../shared/zsh.nix
  ];

  options.my.bundles.laptop = {
    enable = lib.mkEnableOption "Bundle de configuration pour laptop Darwin";
  };

  config = lib.mkIf cfg.enable {
    my.features = {
      aerospace.enable = lib.mkDefault true;
      logseq.enable = lib.mkDefault true;
      terminals.ghostty.enable = lib.mkDefault true;
      homebrew.enable = lib.mkDefault true;
      podman.enable = lib.mkDefault true;
      antigravity-cli.enable = lib.mkDefault true;
      editors.vscode = {
        enable = lib.mkDefault true;
        insiders.enable = lib.mkDefault true;
      };
    };
  };
}
