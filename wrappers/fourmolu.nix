{
  config,
  defaultsPkgs,
  lib,
  pkgs,
  wlib,
  ...
}:

let
  yaml = defaultsPkgs.formats.yaml_1_2 { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Settings for `fourmolu`, written to `fourmolu.yaml`.";
    default = { };
    inherit (yaml) type;
  };

  config = {
    flags."--config" = lib.mkIf (config.settings != { }) (
      yaml.generate "fourmolu.yaml" config.settings
    );
    package = pkgs.fourmolu;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      column-limit = 80;
      haddock-style = "single-line";
      import-grouping = "by-scope";
      indentation = 2;
      let-style = "inline";
      respectful = false;
      sort-constraints = true;
      sort-deriving-classes = true;
      sort-deriving-clauses = true;
    };
  };
}
