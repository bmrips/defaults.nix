{ pkgs, wlib, ... }:

{
  imports = [ wlib.modules.default ];

  config = {
    aliases = [ "jq" ];
    package = pkgs.jaq;
  };
}
