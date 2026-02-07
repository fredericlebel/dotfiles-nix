{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.features.containers;
  inherit (pkgs.stdenv) isDarwin;
in
{
  options.my.features.containers = {
    enable = lib.mkEnableOption "Stack Conteneurs (Podman/Docker)";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          podman-compose
          lazydocker
        ]
        ++ lib.optionals isDarwin [
          pkgs.colima
          pkgs.podman
        ];

      sessionVariables = lib.mkIf isDarwin {
        DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
      };

      shellAliases = {
        d = "podman";
        dc = "podman-compose";
        k = "kubectl";
      }
      // lib.optionalAttrs isDarwin {
        start-colima = "colima start --runtime podman --cpu 2 --memory 4";
      };
    };
  };
}
