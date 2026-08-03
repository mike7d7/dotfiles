To apply new config: `sudo nixos-rebuild switch --flake .`

To apply new config with private flake: `nixos-rebuild switch --elevate=sudo`

To apply new config with stuff from /home/ (ex. CiscoPacketTracer): `sudo nixos-rebuild switch --flake . --impure`

To update: `nix flake update`

To optimise store: `sudo nix-store --optimise`

All previous commands should be executed inside this folder.
