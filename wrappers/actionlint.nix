{
  dlib,
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."-shellcheck" = dlib.mkDefault (lib.getExe pkgs.defaults.shellcheck);
    package = pkgs.actionlint;
  };
}
