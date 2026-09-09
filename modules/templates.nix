{
  config,
  lib,
  pkgs,
  ...
}:

let
  templatesWriter = pkgs.defaults.writeShellApplication {
    name = "write-templates";
    derivationArgs = {
      allowSubstitutes = false;
      preferLocalBuild = true;
    };
    runtimeInputs = [ pkgs.gitMinimal ];
    runtimeEnv.templates = lib.pipe config.templates [
      (lib.mapAttrsToList (target: source: { inherit target source; }))
      (pkgs.writers.writeJSON "templates.json")
    ];
    text = pkgs.writers.writeNu "write-templates" /* nu */ ''
      cd (git rev-parse --show-toplevel)
      for template in (open $env.templates) {
        if not ($template.target | path exists) {
          mkdir ($template.target | path dirname)
          open --raw $template.source | save $template.target
        }
      }
    '';
  };
in
{
  options.templates = lib.mkOption {
    description = ''
      Files that are written into the repository if they are missing. This feature
      is useful to initialize templates, i.e. files that are not structurally
      configurable, on the first development shell launch.

      The key is the target path relative to the git repository root and the
      value is the path to the source.
    '';
    default = { };
    type = with lib.types; attrsOf pathInStore;
  };

  config.make-shells.default.shellHook = lib.mkIf (config.templates != { }) (
    lib.getExe templatesWriter
  );
}
