{ config, lib, ... }:

lib.mkIf config.treefmt.programs.latexindent.enable {
  git.ignore = map (p: "/" + config.ecosystems.tex.root + p) [
    "/*.bak*"
    "/indent\.log"
  ];
}
