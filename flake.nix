{
  description = "Config Nix pour mon MacBook";

  inputs = {
    # Si tu veux de la stabilité, remplace par "github:NixOS/nixpkgs/nixpkgs-24.05-darwin"
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, darwin, nixpkgs, home-manager, nix-homebrew, ... }:
  let
    system = "aarch64-darwin"; 
  in
  {
    darwinConfigurations.caladan = darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.flebel = import ./home.nix;
        }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "flebel";
            # Active Rosetta pour pouvoir installer des apps Intel sur ton Mac M1/M2/M3
            #enableRosetta = true;
            # Migre automatiquement si tu avais déjà un vieux Homebrew
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
