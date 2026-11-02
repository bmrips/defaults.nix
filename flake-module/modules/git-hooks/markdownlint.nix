{
  config,
  dlib,
  lib,
  pkgs,
  ...
}:

{
  pre-commit.settings.hooks.markdownlint = dlib.mkDefault {
    # Set the package explicitly since its name is different from the hook name.
    package = pkgs.defaults.markdownlint-cli;

    # Redeclare the entry since it passes an empty config file by default.
    # See https://github.com/cachix/git-hooks.nix/pull/759
    entry = lib.getExe config.pre-commit.settings.hooks.markdownlint.package;
  };
}
