{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.python.enable = mkCat "Python tooling (pyright, ruff, pyrefly, black, isort, pylsp)";
  config.specs.python = {
    enable = config.languages.python.enable;
    data = null;
    runtimePackages = with pkgs; [
      pyright
      python313Packages.python-lsp-server
      ruff
      pyrefly
      isort
      black
    ];
  };
}
