{ pkgs, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--ignore" = [ "sema-primop-overridden" ];
    package = pkgs.nixf-diagnose;
  };
}
