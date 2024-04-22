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
    vars = {
      user = "george";
    };
    hosts = [
      "nixos-worktop"
      "nixos-thintop"
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (
      map (host: { 
        name = host;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs; 
            inherit vars;
            inherit host;
          };
          modules = [
            ./hosts/${host}/configuration.nix
            ./hosts/${host}/hardware-configuration.nix
            ./modules/common.nix
            home-manager.nixosModules.home-manager {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.user} = import ./home.nix;
                extraSpecialArgs = { 
                  inherit pkgs-unstable;
                  inherit vars;
                  inherit host;
                };            
              };
            }
          ];
        };
      })
      hosts
    );
  };
}
