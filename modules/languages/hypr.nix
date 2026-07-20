{ pkgs, mkCat, config, ... }:
{
  options.languages.hypr.enable = mkCat "Hyprland config tooling (hyprls)";
  config.specs.hypr = {
    enable = config.languages.hypr.enable;
    data = null;
    runtimePackages = with pkgs; [ hyprls ];
  };
}
