{ pkgs, mkCat, config, ... }:
{
  options.languages.json.enable = mkCat "JSON tooling (vscode-langservers-extracted)";
  config.specs.json = {
    enable = config.languages.json.enable;
    data = null;
    runtimePackages = with pkgs; [ vscode-langservers-extracted ];
  };
}
