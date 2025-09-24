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
    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:mike7d7/nix-matlab";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-matlab,
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
