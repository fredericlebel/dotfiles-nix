{
  description = "Config Nix Multi-Host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, ... }:
  let
    user = "flebel";

    mylib = import ./lib/helpers.nix { inherit inputs user; };
  in
  {
    darwinConfigurations = {
      "caladan" = mylib.mkDarwinSystem "caladan";
    };

    nixosConfigurations = {
      "vps-01" = mylib.mkNixosSystem "vps-01";
    };
  };
}
