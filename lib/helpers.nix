{
  inputs,
  user,
  ...
}: let
  myMeta = {
    adminEmail = "flebel@opval.com";
    baseDomain = "opval.com";
    vaultwardenSubdomain = "vaultwarden.ix.opval.com";
  };
in {
  mkSystem = {
    hostName,
    system,
    isDarwin ? false,
  }: let
    builder =
      if isDarwin
      then inputs.darwin.lib.darwinSystem
      else inputs.nixpkgs.lib.nixosSystem;

    osModules =
      if isDarwin
      then [
        inputs.mac-app-util.darwinModules.default
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.sops-nix.darwinModules.sops
      ]
      else [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ];

    homeManagerModule =
      if isDarwin
      then inputs.home-manager.darwinModules.home-manager
      else inputs.home-manager.nixosModules.home-manager;
  in
    builder {
      inherit system;
      specialArgs = {inherit inputs user myMeta;};

      modules =
        osModules
        ++ [
          ../hosts/${hostName}/configuration.nix

          homeManagerModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {inherit inputs user myMeta;};
              users.${user} = {
                imports =
                  [
                    ../hosts/${hostName}/home.nix
                  ]
                  ++ (
                    if isDarwin
                    then [inputs.mac-app-util.homeManagerModules.default]
                    else []
                  );
              };
            };
          }
        ];
    };
}
