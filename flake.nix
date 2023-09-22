{
  description = "My default configuration for tools";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    pre-commit.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      let
        flakeModule = import ./flake-module.nix;
      in
      {
        imports = [
          inputs.pre-commit.flakeModule
          inputs.treefmt.flakeModule
          flakeModule
        ];

        systems = inputs.nixpkgs.lib.platforms.all;

        flake.flakeModule = flakeModule;

        perSystem =
          { config, ... }:
          {
            devShells.default = config.defaults.devShell;
          };
      }
    );
}
