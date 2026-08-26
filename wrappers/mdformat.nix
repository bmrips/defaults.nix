{
  config,
  lib,
  options,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--wrap" = lib.mkDefault "no";
    package = pkgs.mdformat;

    # `passthru` is not preserved by default. See
    # https://github.com/BirdeeHub/nix-wrapper-modules/issues/599

    passthru.withPlugins =
      selector:
      let
        currentPrio = options.overrides.highestPrio or lib.modules.defaultOverridePriority;
      in
      config.wrap { overrides = lib.mkOverride currentPrio [ (base: base.withPlugins selector) ]; };
  };
}
