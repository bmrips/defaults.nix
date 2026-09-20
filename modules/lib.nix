{
  dlib,
  lib,
  root,
  ...
}:

{
  _module.args.dlib = {

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

  };
}
