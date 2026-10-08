{ dlib, pkgs, ... }:

{
  pre-commit.settings.hooks.shellcheck.package = dlib.mkDefault pkgs.defaults.shellcheck;
}
