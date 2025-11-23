{
  description = "NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
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
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nvf = {
      url = "github:NotAShelf/nvf/v0.8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      nix-matlab,
      chaotic,
      nvf,
      ...
    }:
    {
      packages."x86_64-linux".default =
        (nvf.lib.neovimConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./nvf-config.nix ];
        }).neovim;
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs.inputs = inputs;
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.cthulock.nixosModules.x86_64-linux.default
          inputs.nvf.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                pkgs-stable = inputs.nixpkgs-stable.legacyPackages."x86_64-linux";
              };
              users.mig = {
                imports = [ ./home-config.nix ];
              };
            };
          }
        ];
      };
    };
}
