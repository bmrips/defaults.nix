{
  config,
  defaultsPkgs,
  lib,
  options,
  ...
}:

{
  pre-commit.settings.hooks.convco.package = lib.mkIf options.git.upstream.repository.isDefined (
    defaultsPkgs.convco.wrap { settings = config.git.upstream; }
  );
}
