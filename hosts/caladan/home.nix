{user, ...}: {
  imports = [
    ../../users/${user}/base.nix
  ];
  nixpkgs.config.allowUnfree = true;
  my.features = {
    bat.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fzf.enable = true;
    git.enable = true;
    gpg.enable = true;
    htop.enable = true;
    k9s.enable = true;
    neovim.enable = true;
    screen.enable = true;
    starship.enable = true;
    vscode.enable = true;
    wezterm.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
  };
}
