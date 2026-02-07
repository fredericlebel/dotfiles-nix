{
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
in
{
  imports = [
    ./agent.nix
    ./server.nix
  ];

  options.my.features.observability = {
    enable = lib.mkEnableOption "la stack d'observabilité complète";

    role = lib.mkOption {
      type = types.enum [
        "agent"
        "server"
      ];
      default = "agent";
      description = "Le rôle de la machine. 'server' installe Grafana/Prometheus. 'agent' installe juste les exporters.";
    };

    exporters = {
      postgres = {
        enable = lib.mkOption {
          type = types.bool;
          default = config.services.postgresql.enable;
          description = "Active l'exporteur PostgreSQL. Auto-activé si PostgreSQL tourne sur la machine.";
        };

        port = lib.mkOption {
          type = types.port;
          default = 9187;
          description = "Port d'écoute pour l'exporteur Postgres.";
        };
      };
    };
  };
}
