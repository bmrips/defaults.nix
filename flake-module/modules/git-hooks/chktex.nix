{ dlib, pkgs, ... }:

{
  pre-commit.settings.hooks.chktex.package = dlib.mkDefault pkgs.defaults.chktex;
}
