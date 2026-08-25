{ config, lib, ... }:

{
  files.writer.app = true;

  make-shells.default.shellHook = lib.getExe config.files.writer.drv;

  pre-commit.settings.hooks.write-files = {
    enable = config.files.file != { };
    description = "Write the declared files";
    pass_filenames = false;
    always_run = true;
    package = config.files.writer.drv;
    entry = lib.getExe config.pre-commit.settings.hooks.write-files.package;
  };
}
