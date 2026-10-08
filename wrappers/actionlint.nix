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
    flags."-shellcheck" = dlib.mkDefault (lib.getExe (self.defaults or self).shellcheck);
    package = super.actionlint;
  };
}
