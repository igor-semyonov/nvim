{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.cmake.enable = mkCat "CMake tooling (cmake, cmake-language-server, gersemi)";
  config.specs.cmake = {
    enable = config.languages.cmake.enable;
    data = null;
    runtimePackages = with pkgs; [
      cmake
      cmake-language-server
      gersemi
    ];
  };
}
