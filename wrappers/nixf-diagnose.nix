{
  lib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--ignore" = lib.mkDefault [ "sema-primop-overridden" ];
    package = pkgs.nixf-diagnose;
  };
}
