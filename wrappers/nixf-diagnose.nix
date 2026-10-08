{ super, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    flags."--ignore" = [ "sema-primop-overridden" ];
    package = super.nixf-diagnose;
  };
}
