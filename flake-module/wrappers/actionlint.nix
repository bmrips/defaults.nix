{
  dlib,
  lib,
  self,
  super,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."-shellcheck" = dlib.mkDefault (lib.getExe self.defaults.shellcheck);
    package = super.actionlint;
  };
}
