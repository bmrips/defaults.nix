{ config, lib, ... }:

let
  # We can not wrap the top-level configuration with this condition since we
  # would get an infinite recursion:
  #  pre-commit hooks -> treefmt -> latexindent -> gitignore patterns ->
  #  write-files pre-commit hook
  ifEnabled = lib.mkIf config.treefmt.programs.latexindent.enable;
in
{
  git.ignore.${config.ecosystems.tex.root} = ifEnabled [
    "*.bak*"
    "indent\.log"
  ];

  # Do not format packages and document classes, only TeX documents and
  # bibliography files.
  treefmt.settings.formatter = ifEnabled {
    latexindent.includes = lib.mkForce [
      "*.tex"
      "*.bib"
    ];
  };
}
