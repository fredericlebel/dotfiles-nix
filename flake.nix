{
  description = "Infrastructure orchestrée de Frédéric Lebel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      colmena,
      treefmt-nix,
      ...
    }:
    let
      user = "flebel";
      inventory = import ./nix/lib/inventory.nix;
      mylib = import ./nix/lib/helpers.nix { inherit inputs user; };

      nixosHosts = nixpkgs.lib.filterAttrs (_n: v: !v.isDarwin) inventory;
      darwinHosts = nixpkgs.lib.filterAttrs (_n: v: v.isDarwin) inventory;
      colmenaHosts = nixpkgs.lib.filterAttrs (_n: v: v.deployment != null) inventory;

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.nixfmt.package = nixpkgs.legacyPackages.${system}.nixfmt;
        }
      );
    in
    {
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      darwinConfigurations = nixpkgs.lib.mapAttrs (
        name: conf:
        mylib.mkSystem {
          hostName = name;
          inherit (conf) system isDarwin;
        }
      ) darwinHosts;

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        name: conf:
        mylib.mkSystem {
          hostName = name;
          inherit (conf) system isDarwin;
        }
      ) nixosHosts;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          specialArgs = { inherit inputs user; };
        };
      }
      // (nixpkgs.lib.mapAttrs (
        name: conf:
        { ... }:
        {
          deployment = conf.deployment // {
            buildOnTarget = true;
            targetUser = user;
          };
          _module.args.myMeta = mylib.defaultMeta // (import ./hosts/${name}/host-meta.nix);

          imports = [
            ./hosts/${name}/configuration.nix
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = false;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs user; };
                users.${user} = import ./hosts/${name}/home.nix;
              };
            }
          ];
        }
      ) colmenaHosts);

      colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      packages = forAllSystems (
        system:
        let
          matchingHosts = nixpkgs.lib.filterAttrs (_n: v: v.system == system) inventory;
        in
        nixpkgs.lib.mapAttrs' (
          name: conf:
          nixpkgs.lib.nameValuePair name (
            if conf.isDarwin then
              self.darwinConfigurations.${name}.system
            else
              self.nixosConfigurations.${name}.config.system.build.toplevel
          )
        ) matchingHosts
      );
    };
}
