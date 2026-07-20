{
  pkgs,
  mkCat,
  config,
  ...
}: {
  options.languages.nix.enable = mkCat "Nix tooling (nil, nixd, alejandra)";
  config.specs.nix = {
    enable = config.languages.nix.enable;
    data = null;
    runtimePackages = with pkgs; [
      nil
      nixd
      alejandra
    ];
  };
}
