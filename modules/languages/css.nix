{ pkgs, mkCat, config, ... }:
{
  options.languages.css.enable = mkCat "CSS tooling (vscode-langservers-extracted, prettier)";
  config.specs.css = {
    enable = config.languages.css.enable;
    data = null;
    runtimePackages = with pkgs; [
      vscode-langservers-extracted
      prettier
    ];
  };
}
