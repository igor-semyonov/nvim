{ pkgs, lib, mkCat, onLinux, config, ... }:
{
  options.tools.images.enable = mkCat "Image/diagram rendering tools (linux only)";
  config.specs.images = {
    enable = config.tools.images.enable && onLinux;
    data = null;
    runtimePackages = lib.optionals onLinux (with pkgs; [
      imagemagickBig
      luajitPackages.magick
      ghostscript
      mermaid-cli
      ueberzugpp
      cairosvg
    ]);
  };
}
