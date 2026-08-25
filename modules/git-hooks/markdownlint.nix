{ config, lib, ... }:

{
  # Configure the markdownlint hook entry since it passes an empty config file
  # by default.
  pre-commit.settings.hooks.markdownlint.entry =
    lib.getExe config.pre-commit.settings.hooks.markdownlint.package;
}
