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
    src = lib.mkOption {
      description = ''
        The source code for the documents.
      '';
      example = lib.literalExpression "./.";
      default = root;
      defaultText = "self.outPath";
      type = lib.types.path;
    };
    packages = lib.mkOption {
      description = ''
        The packages to be installed in the TeX Live environment. It is a
        function from the TeX Live package set to a list of packages.
      '';
      default = _: [ ];
      defaultText = "(_: [])";
      type = lib.types.anything;
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

    ecosystems.tex.documents = pkgs.stdenvNoCC.mkDerivation {
      name = "documents";
      inherit (cfg) src;
      nativeBuildInputs = [ (pkgs.texliveBasic.withPackages cfg.packages) ];
      preBuild = "export TEXMFVAR=$(mktemp -d)";
    };

    make-shells.default = {
      inputsFrom = [ cfg.documents ];
      shellHook = ''
        export TEXMFVAR=$PWD/.cache/texmf-var
        mkdir -p $TEXMFVAR
      '';
    };
  };
}
