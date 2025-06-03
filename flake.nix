{
  description = "Apple silicon nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      homebrew-cask,
      homebrew-core,
      nix-darwin,
      nix-homebrew,
      rust-overlay,
    }:
    let
      host = "mbp";
      system = "aarch64-darwin";
      user = "moe";

      overlays = [
        rust-overlay.overlays.default
      ]
      ++ builtins.map (name: import (./overlays + "/${name}")) (
        builtins.attrNames (builtins.readDir ./overlays)
      );

      pkgs = import inputs.nixpkgs {
        inherit overlays system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs host user; };

        modules = [
          { nixpkgs = { inherit overlays; }; }

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              mutableTaps = false;
              inherit user;
              taps."homebrew/homebrew-cask" = homebrew-cask;
            };
          }

          ./configuration.nix
        ];
      };
    };
}
