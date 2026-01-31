{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.features.system.nix-maintenance;
in {
  options.my.features.system.nix-maintenance.enable = lib.mkEnableOption "Maintenance Nix";

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    environment.systemPackages = with pkgs; [
      htop
      btop
      curl
    ];
  };
}
