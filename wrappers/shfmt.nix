{
  dlib,
  pkgs,
  wlib,
  ...
}:

{
  imports = [ wlib.modules.default ];

  config = {
    flags = dlib.mkDefault {
      "--indent" = toString 4;
      "--simplify" = true;
    };
    package = pkgs.shfmt;
  };
}
