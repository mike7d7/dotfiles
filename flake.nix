{
  description = "NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cthulock.url = "github:FriederHannenheim/cthulock";
    claypaper.url = "github:mike7d7/clay-paper";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs.inputs = inputs;
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          inputs.cthulock.nixosModules.x86_64-linux.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mig = {
                imports = [ ./home-config.nix ];
              };
            };
          }
        ];
      };
    };

}
