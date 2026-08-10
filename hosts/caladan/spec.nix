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
    antigravity-cli.enable = true;
    terminals.ghostty.enable = true;
    editors.vscode = {
      enable = true;
      insiders.enable = true;
    };
  };

  bundles = {
    laptop.enable = true;
  };
}
