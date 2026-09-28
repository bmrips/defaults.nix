{
  config,
  dlib,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ecosystems.json;
in
{
  options.ecosystems.json.enable = lib.mkEnableOption "tools for JSON development" // {
    default = dlib.hasFileWithExtension "json";
  };

  config = lib.mkIf cfg.enable {
    make-shells.default.packages = [ pkgs.jaq ];
    pre-commit.settings.hooks.check-json.enable = true;

    treefmt.settings.formatter.jaq = {
      includes = [ "*.json" ];
      # jaq supports in-place output but _always_ writes.
      command = pkgs.defaults.writeShellApplication {
        name = "jaq-wrapper";
        derivationArgs = {
          allowSubstitutes = false;
          preferLocalBuild = true;
        };
        runtimeInputs = [ pkgs.jaq ];
        text = /* bash */ ''
          for file in "$@"; do
            formatted=$(jaq --sort-keys . "$file")
            original=$(<"$file")
            if [[ "$formatted" != "$original" ]]; then
              echo "$formatted" >"$file"
            fi
          done
        '';
      };
    };
  };
}
