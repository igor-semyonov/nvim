{ pkgs, mkCat, config, ... }:
{
  options.languages.rust.enable = mkCat "Rust tooling (rust-analyzer, clippy, rustfmt)";
  config.specs.rust = {
    enable = config.languages.rust.enable;
    data = null;
    runtimePackages = with pkgs; [
      rust-analyzer
      clippy
      rustfmt
    ];
  };
}
