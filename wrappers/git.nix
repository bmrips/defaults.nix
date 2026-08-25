{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    description = "Configuration parameters that will be passed to the `-c` flag.";
    default = { };
    type =
      with lib.types;
      let
        scalar = oneOf [
          bool
          int
          str
        ];
        leaf = either scalar (listOf scalar);
      in
      attrsOf (attrsOf (either leaf (attrsOf leaf)));
  };

  config = {
    flags."-c" =
      let
        nonEmptySections = lib.filterAttrsRecursive (_: v: v != { }) config.settings;
        mkValue = x: if builtins.isBool x then if x then "=" else "" else "=${toString x}";
        mkConfig = p: v: lib.concatStringsSep "." p + mkValue v;
      in
      lib.mapAttrsToListRecursive mkConfig nonEmptySections;

    package = pkgs.git;
  };
}
