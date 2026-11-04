{ lib, pkgs, ... }:

{
  # Bypass `formats.yaml_1_2` and call remarshal directly with the
  # `--yaml-style-newline="|"` option to render multiline strings as block
  # literals.
  #
  # See https://github.com/NixOS/nixpkgs/issues/465776 for more information.
  legacyPackages.formats.yaml_1_2 =
    {
      tags ? false,
    }:
    {
      generate =
        name: value:
        let
          options = lib.cli.toCommandLineShellGNU { } {
            yaml-tags = tags;

            # Some YAML parsers like Perl's YAML::Tiny can handle neither line
            # wrapping nor line breaks in scalar strings. Hence, disable
            # wrapping and print strings containing line breaks in block form.
            width = "inf";
            yaml-style-newline = "|";
          };
        in
        pkgs.runCommand name
          {
            nativeBuildInputs = [ pkgs.remarshal ];
            inherit value;
            preferLocalBuild = true;
            __structuredAttrs = true;
          }
          ''
            json2yaml "$NIX_ATTRS_JSON_FILE" --unwrap=value "$out" ${options}
          '';

      type = lib.types.serializableValueWith { typeName = "YAML 1.2"; };
    };

  # Enable shellcheck's optional checks as configured in its wrapper.
  legacyPackages.writeShellApplication =
    let
      optionalChecks = pkgs.defaults.shellcheck.configuration.settings.enable;
    in
    args:
    pkgs.writeShellApplication (
      args
      // {
        extraShellCheckFlags = args.extraShellCheckFlags or [ ] ++ [
          "--enable=${lib.concatStringsSep "," optionalChecks}"
        ];
      }
    );
}
