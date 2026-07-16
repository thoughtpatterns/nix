{
  description = "NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      nix-index-database,
      ...
    }:
    let
      user = "moe";
    in
    {
      nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs user;
          host = "x230";
          home = "/home/${user}";
        };

        modules = [
          nix-index-database.nixosModules.nix-index
          ./hosts/x230
        ];
      };

      darwinConfigurations.imac = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs user;
          host = "imac";
          home = "/Users/${user}";
        };

        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          nix-index-database.darwinModules.nix-index
          ./hosts/imac.nix
        ];
      };
    };
}
