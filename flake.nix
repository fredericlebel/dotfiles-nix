{
  description = "Config Nix Multi-Host de Frédéric Lebel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    user = "flebel";
    # On importe notre helper
    mylib = import ./lib/helpers.nix {inherit inputs user;};

    systems = ["aarch64-darwin" "x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Configurations macOS (Architecture ARM/M1/M2/M3)
    darwinConfigurations = {
      "caladan" = mylib.mkSystem {
        hostName = "caladan";
        system = "aarch64-darwin";
        isDarwin = true;
      };
    };

    # Configurations NixOS (Architecture PC/Cloud)
    nixosConfigurations = {
      "ix" = mylib.mkSystem {
        hostName = "ix";
        system = "x86_64-linux";
      };
    };

    # Raccourcis pour nix build
    packages."aarch64-darwin".default = self.darwinConfigurations."caladan".system;
    packages."x86_64-linux".default = self.nixosConfigurations."ix".system;
  };
}
