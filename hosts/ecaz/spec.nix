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
    tags = [
      "vps"
      "cloud"
    ];
  };

  # Features d intention
  features = {
    zsh.enable = true;
    infrastructure = {
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
