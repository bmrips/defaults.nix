{ super, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    aliases = [ "jq" ];
    package = super.jaq;
  };
}
