{
  config,
  dlib,
  lib,
  ...
}:

let
  texRoot = config.ecosystems.tex.root;
in
lib.mkIf (texRoot != ".") {
  make-shells.default.shellHook = /* bash */ ''
    export CHKTEXRC="$PWD/${texRoot}"
  '';
  pre-commit.settings.hooks.chktex.entry =
    dlib.mkDefault "env CHKTEXRC=${texRoot} ${config.pre-commit.settings.hooks.chktex.package}/bin/chktex";
}
