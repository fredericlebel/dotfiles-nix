{
  description = "Config Nix Multi-Host de Frédéric Lebel";

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
  };

  outputs =
    inputs@{
      self,
      colmena,
      nixpkgs,
      ...
    }:
    let
      user = "flebel";

      mylib = import ./lib/helpers.nix { inherit inputs user; };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      darwinConfigurations = {
        "caladan" = mylib.mkSystem {
          hostName = "caladan";
          system = "aarch64-darwin";
          isDarwin = true;
        };
      };

      nixosConfigurations = {
        "ix" = mylib.mkSystem {
          hostName = "ix";
          system = "x86_64-linux";
          hostMeta = {
            s3Endpoint = "s3.us-west-000.backblazeb2.com";
            s3Bucket = "ix-opval-com";
            vaultwardenSubdomain = "vaultwarden.ix.opval.com";
          };
        };
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          specialArgs = { inherit inputs user; };
        };

        "ix" =
          {
            ...
          }:
          {
            deployment = {
              buildOnTarget = true;
              targetHost = "ix.opval.com";
              targetUser = "flebel";
              tags = [
                "vps"
                "cloud"
              ];
            };

            imports = [
              ./hosts/ix/configuration.nix

              inputs.sops-nix.nixosModules.sops
              inputs.disko.nixosModules.disko

              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = false;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";
                  extraSpecialArgs = { inherit inputs user; };

                  users.${user} = import ./hosts/ix/home.nix;
                };
              }
            ];

            _module.args = {
              myMeta = {
                s3Endpoint = "s3.us-west-000.backblazeb2.com";
                s3Bucket = "ix-opval-com";
                vaultwardenSubdomain = "vaultwarden.ix.opval.com";
                adminEmail = "flebel@opval.com";
                baseDomain = "opval.com";
              };
            };
          };
      };

      packages."aarch64-darwin" = {
        default = self.darwinConfigurations."caladan".system;
        colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      };

      packages."x86_64-linux" = {
        default = self.nixosConfigurations."ix".system;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.git
              pkgs.statix
              pkgs.deadnix
              pkgs.nh
              pkgs.nix-output-monitor
              inputs.colmena.packages.${system}.colmena
            ];

            shellHook = ''
              echo "🚀 Bienvenue dans l'environnement Nix-Config !"
              echo "Outils dispo : colmena, just, sops, nh"
            '';
          };
        }
      );
    };
}
