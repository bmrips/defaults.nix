{
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags = {
      "--indent" = lib.mkDefault (toString 4);
      "--simplify" = lib.mkDefault true;
    };
    package = pkgs.shfmt;
  };
}
