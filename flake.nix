{
  description = "My default configuration for tools";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    haumea.url = "github:nix-community/haumea/v0.2.2";
    make-shell.url = "github:nicknovitski/make-shell";
    make-shell.flake = false;
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    pre-commit.flake = false;
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.flake = false;
  };

  outputs =
    inputs:
    let
      flakeModule = import ./flake-module.nix inputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flakeModule ];

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      flake.flakeModule = flakeModule;

      perSystem.ecosystems.github.enable = true;
    };
}
