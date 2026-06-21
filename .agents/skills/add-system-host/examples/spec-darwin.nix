{
  system = "aarch64-darwin"; # "aarch64-darwin" pour Apple Silicon, "x86_64-darwin" pour Intel Mac
  isDarwin = true;
  deployment = null;

  meta = {
    tags = [
      "laptop"
      "macos"
    ];
  };

  # Features d'intention à activer
  features = {
    zsh.enable = true;
    # aerospace.enable = true;
    # ghostty.enable = true;
  };

  # Bundles d'intention à activer
  bundles = {
    laptop.enable = true;
  };
}
