{
  config,
  lib,
  pkgs,
  root,
  ...
}:

let
  cfg = config.ecosystems.tex;
in
{
  options.ecosystems.tex = {
    enable = lib.mkEnableOption "tools for TeX development";
    root = lib.mkOption {
      description = "The root directory of the document.";
      example = lib.literalExpression "./.";
      default = root;
      defaultText = "self.outPath";
      type = lib.types.path;
    };
    scheme = lib.mkOption {
      description = "The scheme which is used as a base to add packages to.";
      default = pkgs.texliveBasic;
      defaultText = "pkgs.texliveBasic";
      type = lib.types.package;
    };
    packages = lib.mkOption {
      description = ''
        The packages to be installed in the TeX Live environment. It is a
        function from the TeX Live package set to a list of packages.
      '';
      default = _: [ ];
      defaultText = "_: []";
      type = with lib.types; functionTo (listOf package);
    };
    documents = lib.mkOption {
      description = ''
        A derivation containing all documents that are built by the Makefile.
      '';
      type = lib.types.package;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    git = {
      attributes = [
        "*.bib diff=bibtex"
        "*.cls diff=tex"
        "*.sty diff=tex"
        "*.tex diff=tex"
      ];
      ignore = import ./_gitignore.nix;
    };
    pre-commit.settings.hooks.chktex.enable = true;
    treefmt.programs.latexindent.enable = true;

    ecosystems.tex = {
      documents = pkgs.stdenvNoCC.mkDerivation {
        name = "documents";
        src = cfg.root;
        nativeBuildInputs = [ (cfg.scheme.withPackages cfg.packages) ];
      };
      packages = ps: [ ps.latexmk ];
    };

    make-shells.default.inputsFrom = [ cfg.documents ];
  };
}
