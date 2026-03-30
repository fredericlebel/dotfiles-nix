{
  system = "aarch64-darwin";
  isDarwin = true;
  deployment = null;

  meta = {
    tags = [
      "laptop"
      "macos"
    ];
  };

  # Features d intention
  features = {
    zsh.enable = true;
    aerospace.enable = true;
    logseq.enable = true;
    gemini-cli.enable = true;
    terminals.ghostty.enable = true;
  };

  bundles = {
    laptop.enable = true;
  };
}
