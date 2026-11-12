{
  dlib,
  final,
  lib,
  prev,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."-shellcheck" = dlib.mkDefault (lib.getExe final.defaults.shellcheck);
    package = prev.actionlint;
  };
}
