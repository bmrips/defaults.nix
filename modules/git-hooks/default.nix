{ pkgs, ... }:

{
  ecosystems.yaml.enable = true; # for .convco

  pre-commit.settings = {
    package = pkgs.prek;
    hooks = {
      check-added-large-files.enable = true;
      check-merge-conflicts.enable = true;
      check-symlinks.enable = true;
      check-vcs-permalinks.enable = true;
      convco.enable = true;
      detect-private-keys.enable = true;
      mixed-line-endings.enable = true;
      treefmt.enable = true;
      trim-trailing-whitespace.enable = true;
      typos.enable = true;
    };
  };

  treefmt.programs.yamlfmt.includes = [ ".convco" ];
}
