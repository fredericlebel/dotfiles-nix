{
  system = "x86_64-linux";
  isDarwin = false;
  deployment = {
    targetHost = "ecaz.opval.com";
    tags = [
      "vps"
      "cloud"
    ];
  };

  meta = {
    s3Endpoint = "s3.us-west-000.backblazeb2.com";
    s3Bucket = "ecaz-opval-com";
    tags = [
      "vps"
      "cloud"
    ];
  };

  # Features d intention
  features = {
    zsh.enable = true;
    infrastructure = {
      observability = {
        enable = true;
        role = "agent";
        scrapeAddress = "100.87.11.46";
      };
      postgresql = {
        enable = true;
        databases = [ "opentofu" ];
        resticEnable = true;
      };
      tailscale = {
        enable = true;
        isExitNode = true;
      };
    };
  };

  bundles = {
    base-server.enable = true;
  };
}
