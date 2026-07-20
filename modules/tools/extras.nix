{
  pkgs,
  lib,
  mkCat,
  onLinux,
  config,
  ...
}: {
  options.tools.extras.enable = mkCat "Extra tools (ast-grep, lazygit)";
  config.specs.extras = {
    enable = config.tools.extras.enable;
    data = null;
    runtimePackages =
      (with pkgs; [ast-grep])
      ++ lib.optionals onLinux (with pkgs; [lazygit]);
  };
}
