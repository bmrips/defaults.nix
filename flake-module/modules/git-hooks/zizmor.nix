# Change the defaults manually until this PR is merged:
# https://github.com/cachix/git-hooks.nix/pull/734
{
  pre-commit.settings.hooks.zizmor = {
    description = "Static analysis for GitHub Actions";
    files = "(\\.github/(workflows/.*|dependabot.ya?ml))|(action\\.ya?ml)$";
    require_serial = true;
    args = [ "--no-progress" ];
  };
}
