{
  system = "x86_64-linux";
  isDarwin = false;
  deployment = {
    targetHost = "hostname.domain.com";
    tags = [
      "server"
    ];
  };

  meta = {
    tags = [
      "server"
    ];
  };

  # Features d'intention à activer
  features = {
    zsh.enable = true;
    # tailscale.enable = true;
  };
}
