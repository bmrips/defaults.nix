{ config, lib, ... }:

let
  # We can not wrap the top-level configuration with this condition since we
  # would get an infinite recursion:
  #  pre-commit hooks -> treefmt -> latexindent -> gitignore patterns ->
  #  write-files pre-commit hook
  ifEnabled = lib.mkIf config.treefmt.programs.latexindent.enable;
in
{
  git.ignore = ifEnabled (
    # We need to merge here since `config.ecosystems.tex.root` might be `.`
    lib.mkMerge [
      { "." = [ "indent\.log" ]; } # The log is put into the working directory
      { ${config.ecosystems.tex.root} = [ "*.bak*" ]; } # The backup is put relative to the target
    ]
  );

  # Do not format packages and document classes, only TeX documents and
  # bibliography files.
  treefmt.settings.formatter = ifEnabled {
    latexindent.includes = lib.mkForce [
      "*.tex"
      "*.bib"
    ];
  };
}
