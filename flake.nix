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
    dcal = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    custom-rstudio = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mike7d7/nix-cache-test";
    };
    custom-cursors = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+ssh://git@github.com/mike7d7/custom-cursor";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nvf,
    ...
  }: {
    packages."x86_64-linux".default =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [./nvf-config.nix];
      }).neovim;
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      specialArgs.inputs = inputs;
      system = "x86_64-linux";
      modules = [
        {
          nix.settings.substituters = ["http://192.168.0.156:8080/local-cache"];
          nix.settings.trusted-public-keys = [
            "local-cache:O/PCKeQbFg7YTsTXxh8J00Wsy0A6SjlVpC/vV2/gQh8="
          ];
        }
        ./configuration.nix
        home-manager.nixosModules.home-manager
        inputs.nvf.nixosModules.default
        inputs.dcal.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs;
              pkgs-stable = inputs.nixpkgs-stable.legacyPackages."x86_64-linux";
            };
            users.mig = {
              imports = [./home-config.nix];
            };
          };
        }
      ];
    };
  };
}
