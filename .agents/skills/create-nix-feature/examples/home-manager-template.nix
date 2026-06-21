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
    enable = lib.mkEnableOption "Description of the home-manager feature here";
  };

  config = lib.mkIf cfg.enable {
    # Home-manager specific package installation
    home.packages = [
      pkgs.example-user-package
    ];

    # Configuration files managed in the home directory
    # home.file.".config/example/config.toml".text = ''
    #   example_setting = true
    # '';
  };
}
