{ lib, config, ... }:

let
  cfg = config.direnv;
in
{
  options.direnv = {
    enable = lib.mkEnableOption "Direnv integration" // {
      default = true;
    };
    watchedDirectories = lib.mkOption {
      description = "Directories that are watched";
      example = "./modules/";
      default = [ ];
      type = with lib.types; listOf str;
    };
    watchedFiles = lib.mkOption {
      description = "Files that are watched";
      example = "./flake.nix";
      default = [ ];
      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    files.file.".envrc".text = lib.concatLines (
      lib.optional (cfg.watchedFiles != [ ]) "watch_file ${lib.concatStringsSep " " cfg.watchedFiles}"
      ++ lib.map (dir: "watch_dir ${dir}") cfg.watchedDirectories
      ++ [ "use flake .#default" ]
    );

    git.ignore = [ "/.direnv/" ];
  };
}
