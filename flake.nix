{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
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
