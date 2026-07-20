{ pkgs, lib, mkCat, onLinux, config, ... }:
{
  options.languages.latex.enable = mkCat "LaTeX tooling (texlab, ltex, texliveFull, vale)";
  config.specs.latex = {
    enable = config.languages.latex.enable;
    data = null;
    runtimePackages =
      (with pkgs; [
        texlab
        ltex-ls
        ltex-ls-plus
        texliveFull
        vale
      ])
      ++ lib.optionals onLinux (with pkgs; [
        python313Packages.pylatexenc
        pnglatex
      ]);
  };
}
