{
  imports = [
    ./features/infrastructure/caddy.nix
    ./features/infrastructure/home-assistant.nix
    ./features/infrastructure/nix-core.nix
    ./features/infrastructure/postgresql.nix
    ./features/infrastructure/tailscale.nix
    ./features/infrastructure/vaultwarden.nix
    ./features/infrastructure/observability
    ./features/infrastructure/security
    ./features/infrastructure/virtualization/kvm.nix
    ./features/provision/admin-cli.nix
  ];
}
