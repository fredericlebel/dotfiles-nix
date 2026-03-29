{
  system = "x86_64-linux";
  isDarwin = false;
  deployment = {
    targetHost = "ix.opval.com";
    tags = [
      "vps"
      "cloud"
    ];
  };

  # L ancien host-meta.nix
  meta = {
    s3Endpoint = "s3.us-west-000.backblazeb2.com";
    s3Bucket = "ix-opval-com";
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
