{ prev, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    aliases = [ "jq" ];
    package = prev.jaq;
  };
}
