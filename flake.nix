{
  description = "sparrow NixOS config";

  inputs = {
    nixpkgs.url = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, agenix, ... }@inputs: {
    nixosConfigurations.sparrow = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [

        ./hosts/sparrow

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nikhil = import ./home;
          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }

        lanzaboote.nixosModules.lanzaboote
        ({ pkgs, lib, ... }: {
          environment.systemPackages = [ pkgs.sbctl ];
          # Lanzaboote currently replaces the systemd-boot module.
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };
        })

        agenix.nixosModules.default
        { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }

      ];
    };
  };
}
