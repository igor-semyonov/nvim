{ pkgs, mkCat, config, ... }:
{
  options.languages.clang.enable = mkCat "C/C++ tooling (clang-tools)";
  config.specs.clang = {
    enable = config.languages.clang.enable;
    data = null;
    runtimePackages = with pkgs; [ clang-tools ];
  };
}
