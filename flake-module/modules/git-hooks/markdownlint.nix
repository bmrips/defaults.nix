{
  config,
  lib,
  pkgs,
  ...
}:

{
  pre-commit.settings.hooks.markdownlint = {
    # Set the package explicitly since its name is different from the hook name.
    package = pkgs.defaults.markdownlint-cli;

    # Redeclare the entry since it passes an empty config file by default.
    entry = lib.getExe config.pre-commit.settings.hooks.markdownlint.package;
  };
}
