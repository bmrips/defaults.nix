{ prev, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--ignore" = [ "sema-primop-overridden" ];
    package = prev.nixf-diagnose;
  };
}
