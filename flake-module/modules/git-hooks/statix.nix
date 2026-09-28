{ dlib, ... }:

{
  pre-commit.settings.hooks.statix.settings.format = dlib.mkDefault "stderr";
}
