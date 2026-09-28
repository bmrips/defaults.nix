{ config, dlib, ... }:

let
  git-hooks = config.pre-commit.settings;
in
{
  pre-commit.settings.hooks.treefmt.enable = dlib.mkDefault true;
  treefmt.flakeCheck = dlib.mkDefault (!git-hooks.enable || !git-hooks.hooks.treefmt.enable);
}
