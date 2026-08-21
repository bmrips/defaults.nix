{
  config,
  lib,
  pkgs,
  root,
  self',
  ...
}:

let
  cfg = config.ecosystems.haskell;

  # Circumvent a bug in the interaction of Cabal and `shellFor`.
  # https://gist.github.com/ScottFreeCode/ef9f254e2dd91544bba4a068852fc81f
  # https://github.com/NixOS/nixpkgs/issues/130556#issuecomment-2762237786
  cabal-in-nix = pkgs.symlinkJoin {
    name = "cabal-in-nix";
    paths = [ pkgs.cabal-install ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cabal --add-flag --flags=+nix
    '';
  };

  hPkgs = pkgs.haskellPackages;

  ghcDevShell = hPkgs.shellFor {
    packages = _: [ self'.packages.${cfg.cabalPackage.name} ];
    withHoogle = true;
    nativeBuildInputs = [ cabal-in-nix ];
  };
in
{
  options.ecosystems.haskell = {
    enable = lib.mkEnableOption "tools for Haskell development";
    cabalPackage = lib.mkOption {
      description = ''
        Build a contained cabal package. It is made accessible through
        `packages.''${name}` option. The attributes are passed to
        `haskellPackages.developPackage`.
      '';
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          name = lib.mkOption {
            description = ''
              The name of the package. It is used to determine the file name of
              the package description.
            '';
            example = "my-library";
            type = lib.types.str;
          };
          root = lib.mkOption {
            description = ''
              The root directory of the package containing the package description.
            '';
            example = lib.literalExpression "./.";
            default = root;
            defaultText = "self.outPath";
            type = lib.types.pathInStore;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      {
        ecosystems.yaml.enable = true; # for `fourmolu.yaml`
        pre-commit.settings.hooks.hlint.enable = true;
        treefmt.programs.fourmolu.enable = true;
      }

      (lib.mkIf (config.ecosystems.haskell.cabalPackage ? name) {
        direnv.watchedFiles = [ "${cfg.cabalPackage.name}.cabal" ];
        git.ignore = [
          "/cabal.project.local"
          "/cabal.project.local~"
          "/dist-*/"
          "/dist/"
        ];
        make-shells.default.inputsFrom = [ ghcDevShell ];
        packages.${cfg.cabalPackage.name} = hPkgs.developPackage cfg.cabalPackage;
        treefmt.programs.cabal-gild.enable = true;
      })

    ]
  );
}
