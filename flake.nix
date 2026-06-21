{
  description = "Infrastructure orchestrée de Frédéric Lebel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      user = "flebel";
      inherit (nixpkgs) lib;
      helpers = import ./nix/lib/helpers.nix { inherit inputs user; };

      # On lit dynamiquement les hôtes depuis les fichiers spec.nix
      hosts = {
        ix = import ./hosts/ix/spec.nix;
        ecaz = import ./hosts/ecaz/spec.nix;
        caladan = import ./hosts/caladan/spec.nix;
      };

      # Configuration treefmt pour tous les systèmes
      eachSystem = lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      treefmtEval = eachSystem (
        system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.nixfmt.package = nixpkgs.legacyPackages.${system}.nixfmt;
          programs.deadnix.enable = true;
          programs.statix.enable = true;
        }
      );

      # On sépare les configurations Darwin et NixOS
      darwinHosts = lib.filterAttrs (_: spec: spec.isDarwin) hosts;
      nixosHosts = lib.filterAttrs (_: spec: !spec.isDarwin) hosts;

    in
    {
      # Usine à systèmes (Darwin)
      darwinConfigurations = lib.mapAttrs (
        name: spec:
        helpers.mkSystem {
          hostName = name;
          inherit spec;
        }
      ) darwinHosts;

      # Usine à systèmes (NixOS)
      nixosConfigurations = lib.mapAttrs (
        name: spec:
        helpers.mkSystem {
          hostName = name;
          inherit spec;
        }
      ) nixosHosts;

      # Configuration Colmena (Déploiement)
      colmenaHive = inputs.colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs { system = "x86_64-linux"; };
            specialArgs = { inherit inputs user; };
          };
        }
        // (lib.mapAttrs (
          name: spec:
          let
            config = helpers.mkModules {
              hostName = name;
              inherit spec;
            };
          in
          {
            inherit (spec) deployment;
            imports = config.modules;
            _module.args = {
              inherit (config) myMeta;
            };
          }
        ) nixosHosts)
      );

      # Formattage unifié via treefmt
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

      # Checks
      checks = eachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
}
