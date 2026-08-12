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
      helpers = import ./os/nix/lib/helpers.nix { inherit inputs user; };

      # Inventaire centralisé du domaine des hôtes (Single Source of Truth / DDD)
      hosts = import ./os/hosts;

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
          programs.prettier.enable = true;
          settings.global.excludes = [
            ".agents/**"
            "os/secrets/**"
          ];
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
            deployment = {
              targetHost = spec.deployment.targetHost or "${name}.${config.myMeta.connectivity.rootDomain}";
              tags = spec.meta.tags or [ ];
            };
          in
          {
            inherit deployment;
            imports = config.modules;
            _module.args = {
              inherit (config) myMeta;
            };
          }
        ) nixosHosts)
      );

      # Formattage unifié via treefmt
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);

      # Checks (Auto-évaluation des hôtes, de Colmena et du formattage)
      checks = eachSystem (
        system:
        let
          nixosForSystem = lib.filterAttrs (
            _: cfg: cfg.pkgs.stdenv.hostPlatform.system == system
          ) self.nixosConfigurations;
          darwinForSystem = lib.filterAttrs (
            _: cfg: cfg.pkgs.stdenv.hostPlatform.system == system
          ) self.darwinConfigurations;
          colmenaForSystem = lib.filterAttrs (_: drv: drv.system == system) self.colmenaHive.toplevel;

          nixosChecks = lib.mapAttrs' (
            name: cfg: lib.nameValuePair "nixos-${name}" cfg.config.system.build.toplevel
          ) nixosForSystem;
          darwinChecks = lib.mapAttrs' (
            name: cfg: lib.nameValuePair "darwin-${name}" cfg.system
          ) darwinForSystem;
          colmenaChecks = lib.mapAttrs' (name: drv: lib.nameValuePair "colmena-${name}" drv) colmenaForSystem;
        in
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
        // nixosChecks
        // darwinChecks
        // colmenaChecks
      );

      colmena = self.colmenaHive;
    };
}
