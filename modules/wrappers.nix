# Integrate with git-hooks.nix and treefmt.nix

{
  defaultsPkgs,
  lib,
  options,
  ...
}:

let
  # HACK: Inspect the option's definitions to prevent infinite recursion.
  git-hooks = builtins.head (options.pre-commit.settings.type.getSubOptions [ ]).hooks.definitions;
  formatters = (options.treefmt.type.getSubOptions [ ]).programs;
in
{
  pre-commit.settings.hooks = lib.pipe defaultsPkgs [
    (builtins.intersectAttrs git-hooks)
    (lib.mapAttrs (
      _hook: wrapper: {
        # git-hooks.nix sets `package` with default priority, hence we use a
        # lower priority here.
        package = lib.mkOverride 900 wrapper;
      }
    ))
  ];

  treefmt.programs = lib.pipe defaultsPkgs [
    (builtins.intersectAttrs formatters)
    (lib.mapAttrs (_hook: wrapper: { package = lib.mkDefault wrapper; }))
  ];
}
