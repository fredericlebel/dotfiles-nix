{
  description = "Config Nix Multi-Host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    user = "flebel";
    mylib = import ./lib/helpers.nix {inherit inputs user;};

    systems = ["aarch64-darwin" "x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    packages."aarch64-darwin".default = self.darwinConfigurations."caladan".system;
    packages."x86_64-linux".default = self.nixosConfigurations."ix".system;

    darwinConfigurations = {
      "caladan" = mylib.mkDarwinSystem "caladan";
    };

    nixosConfigurations = {
      "ix" = mylib.mkNixosSystem "ix";
    };
  };
}
