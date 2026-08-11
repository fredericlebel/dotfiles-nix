
{

import ../template.nix
// {

  system = "x86_64-linux";
  isDarwin = false;

  # L ancien host-meta.nix
  meta = {
    subdomain = "vault";
    tags = [
      "vps"
      "cloud"
    ];
  };

  # L activation des features (le "Quoi")
  features = {
    zsh.enable = true;
    infrastructure = {
      home-assistant = {
        enable = true;
        subdomain = "hass";
      };
      observability = {
        enable = true;
        role = "server";
        subdomain = "grafana";
      };
      security.suricata = {
        enable = true;
        interface = "ens3";
      };
      tailscale = {
        enable = true;
        isExitNode = true;
      };
      vaultwarden = {
        enable = true;
        subdomain = "vault";
      };
    };
  };
}
