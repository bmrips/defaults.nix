# Integrate with git-hooks.nix and treefmt.nix

{
  dlib,
  lib,
  options,
  pkgs,
  ...
}:

let
  # HACK: Inspect the option's definitions to prevent infinite recursion.
  git-hooks = builtins.head (options.pre-commit.settings.type.getSubOptions [ ]).hooks.definitions;
  formatters = (options.treefmt.type.getSubOptions [ ]).programs;
in
{
  pre-commit.settings.hooks = lib.pipe pkgs.defaults [
    (builtins.intersectAttrs git-hooks)
    (lib.mapAttrs (_hook: wrapper: { package = dlib.mkDefault wrapper; }))
  ];

  treefmt.programs = lib.pipe pkgs.defaults [
    (builtins.intersectAttrs formatters)
    (lib.mapAttrs (_hook: wrapper: { package = dlib.mkDefault wrapper; }))
  ];
}
