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
    description = "Settings for `shellcheck`, written to `shellcheckrc`.";
    default = { };
    type = with lib.types; attrsOf (either str (listOf str));
  };

  config = {
    flags."--rcfile" =
      let
        text = lib.pipe config.settings [
          (lib.mapAttrsToList (
            name: value: if lib.isList value then map (v: "${name}=${v}") value else "${name}=${value}"
          ))
          lib.flatten
          lib.concatLines
        ];
      in
      lib.mkIf (config.settings != { }) (pkgs.writeText "stylua.toml" text);
    package = pkgs.shellcheck;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      shell = "bash";
      enable = [
        # enable optional checks
        "add-default-case"
        "avoid-negated-conditions"
        "avoid-nullary-conditions"
        "check-deprecate-which"
        "check-extra-masked-returns"
        "check-set-e-suppressed"
        "deprecate-which"
        "require-double-brackets"
        "useless-use-of-cat"
      ];
    };
  };
}
