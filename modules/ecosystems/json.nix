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
    make-shells.default.packages = [ pkgs.jq ];
    pre-commit.settings.hooks.check-json.enable = true;

    treefmt.settings.formatter.jq = {
      includes = [ "*.json" ];
      command = pkgs.defaults.writeShellApplication {
        name = "jq-wrapper";
        derivationArgs = {
          allowSubstitutes = false;
          preferLocalBuild = true;
        };
        runtimeInputs = [ pkgs.jq ];
        text = /* bash */ ''
          for file in "$@"; do
            formatted=$(jq . "$file")
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
