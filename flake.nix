{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs-unstable { 
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos-thintop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos-thintop/configuration.nix
        ./hosts/nixos-thintop/hardware-configuration.nix
        ./modules/common.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.george = import ./home.nix;
            extraSpecialArgs = { inherit pkgs-unstable; };
          };
        }
      ];
    };
    nixosConfigurations.nixos-worktop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos-worktop/configuration.nix
        ./hosts/nixos-worktop/hardware-configuration.nix
        ./modules/common.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.george = import ./home.nix;
            extraSpecialArgs = { inherit pkgs-unstable; };
          };
        }
      ];
    };
  };
}
