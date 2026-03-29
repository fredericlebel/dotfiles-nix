{ inputs, user, ... }:
let
  defaultMeta = import ./default-meta.nix;
in
{
  inherit defaultMeta;

  mkSystem =
    {
      hostName,
      spec,
    }:
    let
      # On fusionne les metas par défaut avec celles de la spec
      myMeta = (defaultMeta // (spec.meta or { })) // {
        inherit (spec) system isDarwin;
        tags = (spec.deployment.tags or [ ]) ++ (spec.meta.tags or [ ]);
      };

      isDarwin = spec.isDarwin or false;
      system = spec.system;

      # Pattern Factory : On choisit le constructeur selon l'OS
      builder = if isDarwin then inputs.darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;

      osModules =
        if isDarwin then
          [
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.sops-nix.darwinModules.sops
          ]
        else
          [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];

      hmModule =
        if isDarwin then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    builder {
      # On injecte la spec complete dans specialArgs pour que tous les modules y aient accès
      specialArgs = {
        inherit inputs user myMeta;
        hostSpec = spec;
      };

      modules = osModules ++ [
        { nixpkgs.hostPlatform = system; }
        ../../nix/lib/meta-options.nix
        ../../hosts/${hostName}/configuration.nix
        hmModule
        {
          # On injecte myMeta et on configure Home Manager
          config = {
            myMeta = myMeta;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {
                inherit inputs user myMeta;
                hostSpec = spec;
              };
              users.${user} = {
                imports = [ ../../hosts/${hostName}/home.nix ];
              };
            };
          };
        }
      ];
    };
}
