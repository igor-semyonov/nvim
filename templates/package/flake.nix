{
  description = "Consume igor-semyonov/nvim as a customized package (devShell + package output)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    mynvim.url = "github:igor-semyonov/nvim";
    mynvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    mynvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};

    # `.extendModules` layers your overrides onto the exported module;
    # `.config.wrap` builds the resulting neovim derivation.
    # Every category defaults to enabled upstream — only list what you change.
    myNeovim = (mynvim.wrappers.neovim.extendModules {
      modules = [
        (
          {pkgs, ...}: {
            # Disable a language's tooling (LSPs/formatters dropped from PATH):
            languages.latex.enable = false;

            # Group toggle: drop web tooling as a set...
            groups.web.enable = false;
            # ...but keep one language on (overrides the group's cascade):
            languages.json.enable = true;

            # Or start from nothing and enable only what you want:
            # disableAll = true;
            # groups.web.enable = true;      # -> just the web languages

            # Add extra tools/plugins only in this flake:
            specs.consumer-extras = {
              data = null; # or a plugin / list from pkgs.vimPlugins
              runtimePackages = with pkgs; [gh];
            };
          }
        )
      ];
    }).config.wrap {inherit pkgs;};
  in {
    packages.${system}.default = myNeovim;

    devShells.${system}.default = pkgs.mkShell {
      packages = [myNeovim];
    };
  };
}
