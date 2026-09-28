{ dlib, pkgs, ... }:

{
  make-shells.default.stdenv = dlib.mkDefault pkgs.stdenvNoCC;
}
