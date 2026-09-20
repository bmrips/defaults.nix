{
  config,
  dlib,
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
    enable = lib.mkEnableOption "tools for TeX development" // {
      default = dlib.hasFileWithExtension "tex";
    };
    root = lib.mkOption {
      description = ''
        The directory of the documents relative to the git repository root.
      '';
      default = ".";
      type = lib.types.str;
      apply = path: lib.removePrefix "./" (lib.path.subpath.normalise path);
    };
    engine = lib.mkOption {
      description = "The LaTeX engine to compile the documents with.";
      default = "pdflatex";
      type = lib.types.enum [
        "pdflatex"
        "xelatex"
        "lualatex"
      ];
    };
    texliveEnv = lib.mkOption {
      description = "The TeX Live environment used for the build.";
      default = pkgs.texliveFull;
      defaultText = "pkgs.texliveFull";
      type = lib.types.package;
      apply =
        env:
        if lib.any (drv: drv.pname == "latexmk") env.includedTeXPackages then
          env
        else
          env.withPackages (ps: [ ps.latexmk ]);
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
    ecosystems.tex.documents = pkgs.stdenvNoCC.mkDerivation (
      {
        name = "documents";
        src = root + "/" + cfg.root;
        nativeBuildInputs = [ cfg.texliveEnv ];
      }
      // lib.optionalAttrs (cfg.engine == "lualatex") {
        preBuild = "export TEXMFVAR=$(mktemp -d)";
      }
    );

    files.file."${cfg.root}/latexmkrc".text =
      let
        pdfMode = {
          pdflatex = 1;
          xelatex = 5;
          lualatex = 4;
        };
      in
      # perl
      ''
        $bibtex_use = 1.5; # cleanup .bbl files if all bib files exist
        $out2_dir = ".";
        $out_dir = "build/";
        $pdf_mode = ${toString pdfMode.${cfg.engine}}; # use ${cfg.engine}
        $warnings_as_errors = 1;
      '';

    git = {
      attributes = [
        "*.bib diff=bibtex"
        "*.cls diff=tex"
        "*.sty diff=tex"
        "*.tex diff=tex"
      ];
      ignore.${cfg.root} = [
        "/*.pdf"
        "/*.synctex"
        "/*.synctex.gz"
        "/build/"
      ]
      ++ lib.optionals (cfg.engine == "lualatex") [
        "/.texmf-var"
      ];
    };

    make-shells.default = {
      inputsFrom = [ cfg.documents ];
      shellHook = lib.mkIf (cfg.engine == "lualatex") ''
        export TEXMFVAR=$PWD/${cfg.root}/.texmf-var
        mkdir -p $TEXMFVAR
      '';
    };

    pre-commit.settings.hooks.chktex.enable = true;

    templates."${cfg.root}/Makefile" = ./Makefile;

    treefmt.programs.latexindent.enable = true;
  };
}
