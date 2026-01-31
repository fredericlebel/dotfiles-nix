{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.features.tailscale;
in
{
  options.my.features.tailscale = {
    enable = lib.mkEnableOption "Tailscale Service";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];
  };
}
