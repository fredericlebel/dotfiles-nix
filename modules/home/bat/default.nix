{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.bat;
in
{
  options.my.features.bat = {
    enable = lib.mkEnableOption "bat configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
  };
}
