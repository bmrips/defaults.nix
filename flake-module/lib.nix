{ lib, self, ... }:

let
  root = self.outPath;

  dlib = {

    hasDirectory = path: lib.filesystem.pathIsDirectory "${root}/${path}";

    hasFile = path: lib.filesystem.pathIsRegularFile "${root}/${path}";

    hasFileWith = pred: lib.any pred (lib.filesystem.listFilesRecursive root);

    hasExtension =
      exts:
      if builtins.isString exts then
        file: lib.hasSuffix ".${exts}" file
      else
        file: lib.any (e: lib.hasSuffix ".${e}" file) exts;

    hasFileWithExtension = exts: dlib.hasFileWith (dlib.hasExtension exts);

    # Override with a priority higher than `lib.mkDefault` to sit in between
    # foreign defaults and user's definitions.
    defaultOverridePriority = 500;

    mkDefault = dlib.mkOverride dlib.defaultOverridePriority;

    mkOverride =
      prio:
      let
        go =
          v:
          if builtins.isList v then
            v
          else if builtins.isAttrs v && !lib.isDerivation v then
            if v._type or null == "override" then v else lib.mapAttrs (_: go) v
          else
            lib.mkOverride prio v;
      in
      go;

  };
in
{
  _module.args.dlib = dlib;
  perSystem._module.args.dlib = dlib;
}
