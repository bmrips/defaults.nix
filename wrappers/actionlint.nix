{
  defaultsPkgs,
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."-shellcheck" = lib.mkDefault (lib.getExe defaultsPkgs.shellcheck);
    package = pkgs.actionlint;
  };
}
