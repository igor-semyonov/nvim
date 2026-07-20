{
  description = "A Lua-natic's neovim flake, built with nix-wrapper-modules + flake-parts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # To pull a plugin that isn't in nixpkgs, add it here named `plugins-<name>`
    # and reference it in module.nix via `config.nvim-lib.neovimPlugins.<name>`:
    # plugins-foo = { url = "github:owner/foo"; flake = false; };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      flake-parts,
      ...
    }@inputs:
    let
      # importApply threads `inputs` into module.nix and keeps it a first-class
      # module (so downstream flakes can import it and override options).
      module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ wrappers.flakeModules.wrappers ];
      systems = nixpkgs.lib.platforms.all;

      # Registers the module and auto-generates `packages.<system>.neovim`.
      flake.wrappers.neovim = module;

      # Generically-importable home-manager / nixos modules.
      # Enable with `wrappers.neovim.enable = true;` and set any option.
      flake.nixosModules.neovim = wrappers.lib.getInstallModule {
        name = "neovim";
        value = module;
      };
      flake.nixosModules.default = self.nixosModules.neovim;
      flake.homeModules.neovim = self.nixosModules.neovim;
      flake.homeModules.default = self.nixosModules.neovim;

      # Overlay replacing pkgs.neovim with the wrapped config.
      flake.overlays.neovim = final: _prev: {
        neovim = self.wrappers.neovim.wrap { pkgs = final; };
      };
      flake.overlays.default = self.overlays.neovim;

      perSystem =
        { pkgs, ... }:
        {
          # `wrappers.flakeModules.wrappers` generates `packages.<sys>.neovim`;
          # alias it to `default` so `nix run .` / `nix build .` work.
          packages.default = self.packages.${pkgs.system}.neovim;

          devShells.default = pkgs.mkShell {
            name = "nvim";
            packages = [ self.packages.${pkgs.system}.neovim ];
          };
        };
    };
}
