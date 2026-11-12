{
  dlib,
  super,
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
    package = super.shfmt;
  };
}
