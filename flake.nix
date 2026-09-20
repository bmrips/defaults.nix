{
  description = "My default configuration for tools";

  inputs = {
    files.url = "github:mightyiam/files";
    files.flake = false;
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    make-shell.url = "github:nicknovitski/make-shell";
    make-shell.flake = false;
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit.url = "github:cachix/git-hooks.nix";
    pre-commit.flake = false;
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.flake = false;
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.flake = false;
  };

  outputs =
    inputs:
    let
      flakeModule = import ./flake-module.nix inputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flakeModule
        ./wrappers
      ];

      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      flake.flakeModule = flakeModule;

      flake.overlays.default =
        self: super:
        let
          inherit (self.stdenv.hostPlatform) system;
          packages = inputs.self.packages.${system};
          legacyPackages = inputs.self.legacyPackages.${system};
        in
        super // { defaults = packages // legacyPackages; };

      perSystem = {
        imports = [ ./pkgs-lib.nix ];
        direnv = {
          watchedDirectories = [
            "modules/"
            "wrappers/"
          ];
          watchedFiles = [ "flake-module.nix" ];
        };
      };
    };
}
