{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.template-name;
in
{
  options.my.features.template-name = {
    enable = lib.mkEnableOption "Description of the feature here";
  };

  config = lib.mkIf cfg.enable {
    # System packages to install
    environment.systemPackages = [
      pkgs.example-package
    ];

    # System-level configurations or services
    # services.example-service.enable = true;
  };
}
