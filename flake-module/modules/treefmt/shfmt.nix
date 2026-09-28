{ config, dlib, ... }:

{
  # Configure shfmt because it sets flags by default.
  treefmt.programs.shfmt = dlib.mkDefault {
    indent_size = null;
    simplify = config.treefmt.programs.shfmt.package.configuration.flags."--simplify".data or false;
  };
}
