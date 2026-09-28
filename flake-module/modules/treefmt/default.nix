{ config, ... }:

let
  git-hooks = config.pre-commit.settings;
in
{
  pre-commit.settings.hooks.treefmt.enable = true;
  treefmt.flakeCheck = !git-hooks.enable || !git-hooks.hooks.treefmt.enable;
}
