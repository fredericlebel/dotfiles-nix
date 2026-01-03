{
  inputs,
  user,
  ...
}: let
  pkgs-unstable = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  darwin = inputs.darwin;
  nix-homebrew = inputs.nix-homebrew;
in {
  mkDarwinSystem = hostName:
    darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs user;};
      modules = [
        ../hosts/${hostName}/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs user;};
          home-manager.users.${user} = import ../hosts/${hostName}/home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };

  mkNixosSystem = hostName:
    pkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs user;};
      modules = [
        ../hosts/${hostName}/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs user;};
          home-manager.users.${user} = import ../hosts/${hostName}/home.nix;
        }
      ];
    };
}
