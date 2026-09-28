{ pkgs, ... }:

{
  make-shells.default.stdenv = pkgs.stdenvNoCC;
}
