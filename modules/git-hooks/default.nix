{
  config,
  lib,
  pkgs,
  ...
}:

{
  ecosystems = {
    toml.enable = true; # for typos.toml
    yaml.enable = true; # for .convco
  };

  make-shells.default.inputsFrom = lib.optional config.pre-commit.settings.enable config.pre-commit.devShell;

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
