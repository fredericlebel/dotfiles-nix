{ inputs, user, ... }:
let
  defaultMeta = import ./default-meta.nix;

  # Prépare les modules et arguments pour un système (NixOS, Darwin ou Colmena)
  mkModules =
    {
      hostName,
      spec,
    }:
    let
      lib = inputs.nixpkgs.lib;
      myMeta = (defaultMeta // (spec.meta or { })) // {
        inherit (spec) system isDarwin;
        tags = (spec.deployment.tags or [ ]) ++ (spec.meta.tags or [ ]);
        hostSpec = spec; # On injecte la spec complete pour eviter la recursion
      };

      isDarwin = spec.isDarwin or false;
      inherit (spec) system;

      sopsFile = ../../secrets/${hostName}.yaml;
      hasSops = builtins.pathExists sopsFile;

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

      specialArgs = {
        inherit inputs user myMeta;
      };

      modules = osModules ++ [
        { nixpkgs.hostPlatform = system; }
        ../../modules/shared/registry.nix
        ../../nix/lib/meta-options.nix
        ../../hosts/${hostName}/configuration.nix
        hmModule
        {
          config = {
            inherit myMeta;
            sops.defaultSopsFile = lib.mkIf hasSops sopsFile;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = specialArgs;
              users.${user} = {
                imports = [
                  ../../modules/shared/registry.nix
                  ../../hosts/${hostName}/home.nix
                ];
              };
            };
          };
        }
      ];
    in
    {
      inherit
        modules
        specialArgs
        myMeta
        system
        isDarwin
        ;
    };
in
{
  inherit defaultMeta mkModules;

  # Calcule les métadonnées finales pour un hôte
  mkMeta =
    { spec }:
    (defaultMeta // (spec.meta or { }))
    // {
      inherit (spec) system isDarwin;
      tags = (spec.deployment.tags or [ ]) ++ (spec.meta.tags or [ ]);
    };

  # Construit le système final via nixosSystem ou darwinSystem
  mkSystem =
    args:
    let
      config = mkModules args;
      builder =
        if config.isDarwin then inputs.darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
    in
    builder {
      inherit (config) modules specialArgs;
    };
}
