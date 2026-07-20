{ pkgs, mkCat, config, ... }:
{
  options.languages.html.enable = mkCat "HTML tooling (vscode-langservers-extracted, prettier)";
  config.specs.html = {
    enable = config.languages.html.enable;
    data = null;
    runtimePackages = with pkgs; [
      vscode-langservers-extracted
      prettier
    ];
  };
}
