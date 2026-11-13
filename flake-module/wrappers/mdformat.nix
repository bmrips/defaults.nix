{
  config,
  dlib,
  lib,
  options,
  prev,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  options.plugins = lib.mkOption {
    description = "Plugins to be installed.";
    example = lib.literalExpression "ps: [ ps.mdformat-gfm ]";
    default = _: [ ];
    type = wlib.types.withPackagesType;
  };

  config = {
    flags."--wrap" = dlib.mkDefault "no";
    overrides = [ (package: package.withPlugins config.plugins) ];
    package = prev.mdformat;

    # `passthru` is not preserved by default. See
    # https://github.com/BirdeeHub/nix-wrapper-modules/issues/599
    passthru.withPlugins =
      selector:
      let
        currentPrio = options.overrides.highestPrio or lib.modules.defaultOverridePriority;
      in
      config.wrap { plugins = lib.mkOverride currentPrio selector; };
  };
}
