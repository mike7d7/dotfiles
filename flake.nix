{
  description = "NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:mike7d7/nix-matlab";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-kernel = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mike7d7/custom-kernel";
    };
    handy = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cjpais/Handy";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell?rev=783c953987dc56ff0601abe6845ed96f1d00495a";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waylandar = {
      url = "github:samjoshuadud/waylandar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nvf,
      custom-kernel,
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
          {
            nix.settings.substituters = [ "https://cache.garnix.io" ];
            nix.settings.trusted-public-keys = [
              "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            ];
          }
          ./configuration.nix
          home-manager.nixosModules.home-manager
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
