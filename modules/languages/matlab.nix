{ pkgs, mkCat, config, ... }:
{
  options.languages.matlab.enable = mkCat "MATLAB tooling (matlab-language-server)";
  config.specs.matlab = {
    enable = config.languages.matlab.enable;
    data = null;
    runtimePackages = with pkgs; [ matlab-language-server ];
  };
}
