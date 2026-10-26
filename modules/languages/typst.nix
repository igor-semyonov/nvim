{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.typst.enable = mkCat "Typst tooling (tinymist, typst, typstyle, typst-preview)";
  config.specs.typst = {
    enable = config.languages.typst.enable;
    data = with pkgs.vimPlugins; [
      typst-preview-nvim # nixpkgs patches in tinymist/websocat store paths
    ];
    runtimePackages = with pkgs; [
      typst
      tinymist
      typstyle
    ];
  };
}
