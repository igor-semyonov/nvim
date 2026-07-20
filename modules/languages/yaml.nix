{ pkgs, mkCat, config, ... }:
{
  options.languages.yaml.enable = mkCat "YAML tooling (yaml-language-server, yamlfmt)";
  config.specs.yaml = {
    enable = config.languages.yaml.enable;
    data = null;
    runtimePackages = with pkgs; [ yaml-language-server ];
  };
}
