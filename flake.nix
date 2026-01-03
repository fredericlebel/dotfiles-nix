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
    formatter = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.writeShellScriptBin "nixfmt" ''
          ${pkgs.alejandra}/bin/alejandra .
        ''
    );

    packages."aarch64-darwin".default = self.darwinConfigurations."caladan".system;
    packages."x86_64-linux".default = self.nixosConfigurations."vps-01".system;

    darwinConfigurations = {
      "caladan" = mylib.mkDarwinSystem "caladan";
    };

    nixosConfigurations = {
      "vps-01" = mylib.mkNixosSystem "vps-01";
    };
  };
}
