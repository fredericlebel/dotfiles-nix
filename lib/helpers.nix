{
  inputs,
  user,
  ...
}: let
  mac-app-util = inputs.mac-app-util;
  pkgs-unstable = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  darwin = inputs.darwin;
  nix-homebrew = inputs.nix-homebrew;
  disko = inputs.disko;
in {
  mkDarwinSystem = hostName:
    darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs user;};

      modules = [
        mac-app-util.darwinModules.default
        ../hosts/${hostName}/default.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs user;};
          home-manager.users.${user} = {
            imports = [
              ../hosts/${hostName}/home.nix
              mac-app-util.homeManagerModules.default
            ];
          };
        }

        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  mkNixosSystem = hostName:
    pkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs user;};
      modules = [
        disko.nixosModules.disko
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
