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
        pkgs.runCommand name
          {
            nativeBuildInputs = [ pkgs.remarshal ];
            inherit value;
            preferLocalBuild = true;
            __structuredAttrs = true;
          }
          ''
            json2yaml${lib.optionalString tags " --yaml-tags"} --yaml-style-newline="|" "$NIX_ATTRS_JSON_FILE" --unwrap=value "$out"
          '';

      type = lib.types.serializableValueWith { typeName = "YAML 1.2"; };
    };
}
