{
  config,
  dlib,
  lib,
  ...
}:

{
  # Redeclare the entry since it passes an empty config file by default.
  # See https://github.com/cachix/git-hooks.nix/pull/759.
  pre-commit.settings.hooks.markdownlint.entry = dlib.mkDefault (
    lib.getExe config.pre-commit.settings.hooks.markdownlint.package
  );
}
