{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--wrap" = lib.mkDefault "no";
    package = pkgs.mdformat;

    # `passthru` is currently not preserved.
    # https://github.com/BirdeeHub/nix-wrapper-modules/issues/599
    passthru.withPlugins = config.package.withPlugins;
  };
}
